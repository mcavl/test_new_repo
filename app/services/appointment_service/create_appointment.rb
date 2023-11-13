# frozen_string_literal: true

module AppointmentService
  class CreateAppointment < BaseService
    def call
      validate_start_time
      validate_end_time
      validate_patient_availability
      validate_practitioner_availability
      # Lock and create a booking
      ApplicationRecord.transaction do
        Appointment.create!(clinic:, practitioner_id: arguments[:practitioner_id], patient_id: arguments[:patient_id],
                            start_time:, end_time:, appointment_type: arguments[:appointment_type])
      end
    end

    private

    def start_time
      @start_time ||= TimeUtils.time_from_timezone(clinic.timezone, arguments[:start_time])
    end

    def end_time
      @end_time ||= start_time + Appointments::AppointmentTypes::DURATION[arguments[:appointment_type]]
    end

    # Checks if start time complies with all requirements
    def validate_start_time
      if start_time < clinic.opening_time(arguments[:start_time])
        raise ::AppointmentService::Errors::ClinicIsClosed,
              "Clinic opens at #{clinic.open_time}"
      end

      unless minimum_allowed_start_time
        raise ::AppointmentService::Errors::TimeNotAvailable, 'Appointments cannot be made within 2 hours of the appointment start time.'
      end
      raise ::AppointmentService::Errors::TimeNotAvailable, 'Appointments start on the hour or half-hour.' unless valid_start_time_format
    end

    def valid_start_time_format
      start_time.min.zero? || start_time.min == 30
    end

    def minimum_allowed_start_time
      start_time >= Time.find_zone(clinic.timezone).now + 2.hours
    end

    # Checks if end time complies with all requirements
    def validate_end_time
      return unless end_time > clinic.closing_time(arguments[:start_time])

      raise ::AppointmentService::Errors::ClinicIsClosed,
            "Clinic closes at #{clinic.close_time}"
    end

    # Checks if a patient is not booked already at the same start time
    def validate_patient_availability
      patient_appointment = Appointment.patient_is_booked_at(arguments[:patient_id], arguments[:clinic_id],
                                                             start_time)
      raise ::AppointmentService::Errors::PatientAlreadyBooked, 'Patient already booked' unless patient_appointment.blank?
    end

    def validate_practitioner_availability
      practitioner_appointment = Appointment.practitioner_is_booked_at(arguments[:practitioner_id], arguments[:clinic_id],
                                                                       start_time)
      raise ::AppointmentService::Errors::PractitionerNotAvailable, 'Practitioner already booked' unless practitioner_appointment.blank?
    end
  end
end
