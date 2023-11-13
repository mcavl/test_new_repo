# frozen_string_literal: true

# frozen_string_literal: true

module AppointmentService
  class AppointmentAvailability < BaseService
    INPUT = Struct.new(:practitioner_id, :clinic_id, :date, :appointment_type, keyword_init: true)

    def call
      validate_date
      practitioner_available_time_for_appointment_type
    end

    private

    def validate_date
      return unless Date.parse(arguments.date) < Date.today

      raise ::AppointmentService::Errors::DateInThePast, 'Date should be greater or equals today'
    end

    # Using a 2 pointer approach, this method creates all possible appointments on a day, based on appointment type
    # It will loop through these 2 arrays and only add the available times excluding practitioner's agenda
    def practitioner_available_time_for_appointment_type
      ## Variable Initialization
      # Initialize indexes
      index_daily_appointments = 0
      index_practitioner_appointments = 0
      # Availability contains the result
      availability = []
      # Generate all possible daily appointments
      daily_appointments = generate_daily_appointments

      # Loop while both indexes are valid
      while index_daily_appointments < daily_appointments.size &&
            index_practitioner_appointments < practitioner_appointments.size
        # get current data
        current_available_appointment = daily_appointments[index_daily_appointments]
        current_practitioner_appointment = practitioner_appointments[index_practitioner_appointments]
        # if current appointment is before next practitioner's appointment, add it
        if current_available_appointment.less_or_equal(current_practitioner_appointment)
          availability << current_available_appointment
        # if current appointment is right after next practitioner's appointment, add it
        # and move practitioner's index
        elsif current_available_appointment.greater_or_equal(current_practitioner_appointment)
          availability << current_available_appointment
          # move practitioner index
          index_practitioner_appointments += 1
        end
        # always move daily appointment index
        index_daily_appointments += 1
      end
      # last loop will exit once practitioner's index reach maximum, so we might have some
      # remaining available spots. This method will add them all
      add_remaining_appointments(index_daily_appointments, daily_appointments, availability)
      # return current availability
      availability
    end

    def add_remaining_appointments(last_index, daily_appointments, availability)
      return if last_index >= daily_appointments.size

      (last_index...daily_appointments.size).each do |idx|
        availability << daily_appointments[idx]
      end
    end

    def possible_start_time
      return next_available_start_time if Time.parse(arguments.date).to_date == Time.now.to_date

      clinic.opening_time(arguments.date)
    end

    def next_available_start_time
      now = Time.now
      min = now.min <= 30 ? 30 : 0
      hour = now.min <= 30 ? Time.now.hour + 2 : Time.now.hour + 3
      Time.new(now.year, now.month, now.day, hour, min, 0, ActiveSupport::TimeZone[clinic.timezone])
    end

    def generate_daily_appointments
      available_appointments = []
      start_time = possible_start_time
      while start_time <= last_start_time
        end_time = start_time + Appointments::AppointmentTypes::DURATION[arguments.appointment_type]
        available_appointments.push(::AppointmentService::AppointmentSlot.new(start_time:, end_time:))
        start_time += 30.minutes
      end
      available_appointments
    end

    def last_start_time
      @last_start_time ||= clinic.closing_time(arguments.date) -
                           Appointments::AppointmentTypes::DURATION[arguments.appointment_type]
    end

    def practitioner_appointments
      @practitioner_appointments ||= find_practitioner_appointments
    end

    def find_practitioner_appointments
      args = ::AppointmentService::PractitionerAppointments::INPUT.new(
        practitioner_id: arguments.practitioner_id,
        clinic_id: arguments.clinic_id,
        date: arguments.date
      )
      appointments = ::AppointmentService::PractitionerAppointments.call args
      appointments.map do |appointment|
        ::AppointmentService::AppointmentSlot.new(start_time: appointment.start_time, end_time: appointment.end_time)
      end
    end
  end
end
