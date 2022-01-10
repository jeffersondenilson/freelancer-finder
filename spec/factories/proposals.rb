FactoryBot.define do
  factory :proposal do
    message { FFaker::Lorem.paragraph }
    value_per_hour { FFaker::Number.decimal }
    hours_per_week { FFaker::Number.number + 1 }
    finish_date { 1.week.from_now }
    project
    professional { create(:full_profile_professional) }
  end
end
