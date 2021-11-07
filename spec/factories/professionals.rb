FactoryBot.define do
  factory :professional do
    name { FFaker::Name.unique.first_name }
    email { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
  end

  factory :completed_profile_professional, parent: :professional do
    birth_date { FFaker::Time.date }
    completed_profile { true }
  end

  factory :full_profile_professional, parent: :completed_profile_professional do
    full_name { FFaker::Name.unique.first_name }
    education { FFaker::Education.degree }
    description { FFaker::Lorem.paragraph }
    experience { FFaker::Job.title }
    abilities { FFaker::Skill.specialties }
    profile_picture_url { FFaker::Avatar.image }
  end
end
