# frozen_string_literal: true

# == Schema Information
#
# Table name: clinics
#
#  id         :integer          not null, primary key
#  close_time :string
#  name       :string
#  open_time  :string
#  timezone   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Clinic < ApplicationRecord
  has_many :appointments
  has_many :practitioners
  has_many :patients

  validates :name, :close_time, :open_time, :timezone, presence: true

  def closing_time(time = nil)
    time = current_time if time.nil?

    TimeUtils.time_from_timezone(timezone, "#{time.to_date} #{close_time}")
  end

  def opening_time(time = nil)
    time = current_time if time.nil?

    TimeUtils.time_from_timezone(timezone, "#{time.to_date} #{open_time}")
  end

  def current_time
    Time.now.in_time_zone(timezone)
  end

  def next_available_start_time
    now = current_time
    hour, min = next_valid_time(now)
    Time.new(now.year, now.month, now.day, hour, min, 0, ActiveSupport::TimeZone[timezone])
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
    open_time.split(':').first.to_i
  end

  def opening_minute
    open_time.split(':').second.to_i
  end

  def closing_hour
    close_time.split(':').first.to_i
  end

  def closing_minute
    close_time.split(':').second.to_i
  end

  def next_valid_minute(now)
    return 0 if now.min.zero?

    now.min <= 30 ? 30 : 0
  end
end
