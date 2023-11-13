# frozen_string_literal: true

module AppointmentService
  class AppointmentSlot
    attr_reader :start_time, :end_time

    def initialize(start_time:, end_time:)
      @start_time = start_time
      @end_time = end_time
    end

    def less_or_equal(comparable)
      start_time < comparable.start_time && end_time <= comparable.start_time
    end

    def greater_or_equal(comparable)
      start_time >= comparable.end_time && end_time > comparable.end_time
    end

    def to_iso8601(timezone = nil)
      timezone ||= ActiveSupport::TimeZone[Time.zone.name]
      {
        start_time: start_time.in_time_zone(timezone).iso8601,
        end_time: end_time.in_time_zone(timezone).iso8601
      }
    end
  end
end
