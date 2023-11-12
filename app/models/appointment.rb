class Appointment < ApplicationRecord
  belongs_to :practitioner
  belongs_to :patient
  belongs_to :clinic
end
