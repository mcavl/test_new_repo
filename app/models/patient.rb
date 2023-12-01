# == Schema Information
#
# Table name: patients
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  clinic_id  :integer          not null
#
# Indexes
#
#  index_patients_on_clinic_id  (clinic_id)
#
# Foreign Keys
#
#  clinic_id  (clinic_id => clinics.id)
#
class Patient < ApplicationRecord
  belongs_to :clinic
  has_many :appointments
end
