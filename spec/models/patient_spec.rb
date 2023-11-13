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
require 'rails_helper'

RSpec.describe Patient, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
