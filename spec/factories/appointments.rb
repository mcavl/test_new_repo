FactoryBot.define do
  factory :appointment do
    start_time { "2023-11-12 14:34:45" }
    end_time { "2023-11-12 14:34:45" }
    appointment_type { "MyString" }
    practitioner { nil }
    patient { nil }
    clinic { nil }
  end
end
