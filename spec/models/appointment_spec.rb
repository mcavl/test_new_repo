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
require 'rails_helper'

RSpec.describe Appointment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
