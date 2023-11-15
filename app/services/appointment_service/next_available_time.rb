# frozen_string_literal: true
module AppointmentService
class NextAvailableTime < BaseService
  INPUT = Struct.new(:clinic_id, keyword_init: true)

  def call
    now = clinic.current_time
    hour, min = next_valid_time(now)
    Time.new(now.year, now.month, now.day, hour, min, 0, ActiveSupport::TimeZone[clinic.timezone])
  end

  private

  def next_valid_time(now)
    hour = now.min <= 30 ? now.hour + 2 : now.hour + 3
    min = next_valid_minute(now)
    if hour < opening_hour
      return [opening_hour, opening_minute]
    elsif hour >= closing_hour
      return [closing_hour, closing_minute]
    end

    [hour, min]
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

  def next_valid_minute(now)
    return 0 if now.min.zero?

    now.min <= 30 ? 30 : 0
  end
end
end
