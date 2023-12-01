# frozen_string_literal: true

module AppointmentService
  ##
  # CreateAppointment is responsible for creating an appointment for a patient on a specific day.
  # Both practitioner and patient shouldn't have an overlapping appointment, and it should meet
  # clinic's hours.
  class CreateAppointment < BaseService
    # Service input arguments
    INPUT = Struct.new(:clinic_id, :clinic, :practitioner_id, :patient_id, :start_time, :appointment_type, keyword_init: true)
    def call
      validations
      # Lock and create a booking
      ApplicationRecord.transaction do
        Appointment.create!(clinic:, practitioner_id: arguments.practitioner_id, patient_id: arguments.patient_id,
                            start_time:, end_time:, appointment_type: arguments.appointment_type)
      end
    end

    private

    def validations
      validate_start_time
      validate_end_time
      validate_patient_availability
      validate_practitioner_availability
    end

    def start_time
      @start_time ||= TimeUtils.time_from_timezone(clinic.timezone, arguments.start_time)
    end

    def end_time
      @end_time ||= start_time + Appointments::AppointmentTypes::DURATION[arguments.appointment_type]
    end

    # Checks if start time complies with all requirements
    def validate_start_time
      if start_time <= clinic.opening_time(arguments.start_time)
        raise ::AppointmentService::Errors::ClinicIsClosed,
              "Clinic opens at #{clinic.open_time}"
      end

      unless minimum_allowed_start_time
        raise ::AppointmentService::Errors::TimeNotAvailable,
              'Appointments cannot be made within 2 hours of the appointment start time.'
      end
      return if valid_start_time_format

      raise ::AppointmentService::Errors::TimeNotAvailable, 'Appointments start on the hour or half-hour.'
    end

    def valid_start_time_format
      min = start_time.min
      min.zero? || min == 30
    end

    def minimum_allowed_start_time
      start_time >= ::AppointmentService::NextAvailableTime.call(
        ::AppointmentService::NextAvailableTime::INPUT.new(clinic:)
      )
    end

    # Checks if end time complies with all requirements
    def validate_end_time
      return unless end_time > clinic.closing_time(arguments.start_time)

      raise ::AppointmentService::Errors::ClinicIsClosed,
            "Clinic closes at #{clinic.close_time}"
    end

    # Checks if a patient is not booked already at the same start time
    def validate_patient_availability
      patient_appointment = Appointment.patient_is_booked_at(arguments.patient_id, clinic_id, start_time)
      return if patient_appointment.blank?

      raise ::AppointmentService::Errors::PatientAlreadyBooked, 'Patient already booked'
    end

    def validate_practitioner_availability
      practitioner_appointment = Appointment.practitioner_is_booked_at(arguments.practitioner_id, clinic_id, start_time)
      return if practitioner_appointment.blank?

      raise ::AppointmentService::Errors::PractitionerNotAvailable, 'Practitioner already booked'
    end
  end
end
