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
    time = Time.now if time.nil?

    TimeUtils.time_from_timezone(timezone, "#{time.to_date.to_s} #{close_time}")
  end

  def opening_time(time = nil)
    time = Time.now if time.nil?

    TimeUtils.time_from_timezone(timezone, "#{time.to_date.to_s} #{open_time}")
  end
end
