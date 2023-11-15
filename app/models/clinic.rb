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
end
