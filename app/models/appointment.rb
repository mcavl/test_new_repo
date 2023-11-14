# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id               :integer          not null, primary key
#  appointment_type :string           not null
#  end_time         :datetime         not null
#  start_time       :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  clinic_id        :integer          not null
#  patient_id       :integer          not null
#  practitioner_id  :integer          not null
#
# Indexes
#
#  index_appointments_on_clinic_id                      (clinic_id)
#  index_appointments_on_clinic_id_and_patient_id       (clinic_id,patient_id)
#  index_appointments_on_clinic_id_and_practitioner_id  (clinic_id,practitioner_id)
#  index_appointments_on_patient_id                     (patient_id)
#  index_appointments_on_practitioner_id                (practitioner_id)
#
# Foreign Keys
#
#  clinic_id        (clinic_id => clinics.id)
#  patient_id       (patient_id => patients.id)
#  practitioner_id  (practitioner_id => practitioners.id)
#
class Appointment < ApplicationRecord
  REFERENCES = {
    patient_id: Patient,
    practitioner_id: Practitioner
  }.freeze

  belongs_to :practitioner
  belongs_to :patient
  belongs_to :clinic
  enum appointment_type: Appointments::AppointmentTypes::TYPES

  validates :start_time, :end_time, presence: true

  validate :should_belong_to_same_clinic
  validate :booking_period_validation

  scope :practitioner_is_booked_at, lambda { |practitioner_id, clinic_id, start_time|
    where(practitioner_id:)
      .where(clinic_id:)
      .where(start_time: ..start_time)
      .where(end_time: start_time..)
  }

  scope :practitioner_agenda_on, lambda { |practitioner_id, clinic_id, date|
    where(practitioner_id:)
      .where(clinic_id:)
      .where(start_time: date.beginning_of_day..date.end_of_day)
      .order(:start_time)
  }

  scope :patient_is_booked_at, lambda { |patient_id, clinic_id, start_time|
    where(patient_id:).where(clinic_id:).where(start_time: ..start_time).where(end_time: start_time..)
  }

  private

  def should_belong_to_same_clinic
    REFERENCES.each do |field, klass|
      current_value = self[field]
      next if current_value.nil?

      obj = klass.find_by(id: current_value)
      errors.add(field, 'should belong to same clinic') if obj.clinic_id != self[:clinic_id]
    end
  end

  def booking_period_validation
    return unless end_time.present? && start_time.present?

    errors.add(:end_time, "can't be before start_time") if (end_time - start_time).negative?
  end
end
