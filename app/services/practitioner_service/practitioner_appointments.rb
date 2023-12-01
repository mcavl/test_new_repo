# frozen_string_literal: true

module PractitionerService
  ##
  # PractitionerAppointments returns all appointments for a Practitioner on a specific day
  # Clinic should be passed, so results can be properly scoped.
  class PractitionerAppointments < BaseService
    INPUT = Struct.new(:practitioner_id, :clinic, :clinic_id, :date, keyword_init: true)

    def call
      validate_date
      practitioner_appointments
    end

    private

    def validate_date
      return unless Date.parse(arguments.date) < Date.today

      raise ::AppointmentService::Errors::DateInThePast, 'Date should be greater or equals today'
    end

    def practitioner_appointments
      Appointment.practitioner_agenda_on(
        arguments.practitioner_id,
        clinic.id,
        TimeUtils.time_from_timezone(clinic.timezone, arguments.date)
      )
    end
  end
end
