FactoryBot.define do
  factory :project do
    title { FFaker::Lorem.phrase }
    description { FFaker::Lorem.paragraph }
    desired_abilities { FFaker::Skill.specialties.join(', ') }
    value_per_hour { 9.99 }
    due_date { 1.week.from_now }
    remote { true }
    creator
  end
end
