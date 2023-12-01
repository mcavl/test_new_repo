# frozen_string_literal: true

module AppointmentService
  ##
  # This class represents a service that returns the next available time for scheduling an appointment ona specific clinic
  # It receives 'clinic_id' as input
  class NextAvailableTime < BaseService
    # By using this struct makes it clearer to know which properties a generic 'arguments' variable has
    INPUT = Struct.new(:clinic_id, :clinic, keyword_init: true)

    def call
      now = clinic.current_time
      hour, min = next_valid_time(now)
      Time.new(now.year, now.month, now.day, hour, min, 0, ActiveSupport::TimeZone[clinic.timezone])
    end

    private

    def next_valid_time(now)
      hour = next_valid_hour(now)
      if hour < opening_hour
        return [opening_hour, opening_minute]
      elsif hour >= closing_hour
        return [closing_hour, closing_minute]
      end

      [hour, next_valid_minute(now)]
    end

    def opening_hour
      clinic.open_time.split(':').first.to_i
    end

    def opening_minute
      clinic.open_time.split(':').second.to_i
    end

    def closing_hour
      clinic.close_time.split(':').first.to_i
    end

    def closing_minute
      clinic.close_time.split(':').second.to_i
    end

    def next_valid_hour(now)
      hour = now.hour
      now.min <= 30 ? hour + 2 : hour + 3
    end

    def next_valid_minute(now)
      min = now.min
      return 0 if min.zero?

      min <= 30 ? 30 : 0
    end
  end
end
