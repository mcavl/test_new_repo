# == Schema Information
#
# Table name: practitioners
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  specialty  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  clinic_id  :integer          not null
#
# Indexes
#
#  index_practitioners_on_clinic_id  (clinic_id)
#
# Foreign Keys
#
#  clinic_id  (clinic_id => clinics.id)
#
FactoryBot.define do
  factory :practitioner do

  end
end
