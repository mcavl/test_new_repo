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
FactoryBot.define do
  factory :clinic do
    name { "MyString" }
    open_time { "MyString" }
    close_time { "MyString" }
    timezone { "MyString" }
  end
end
