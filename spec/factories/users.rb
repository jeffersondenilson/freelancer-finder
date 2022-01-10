FactoryBot.define do
  factory :user, aliases: [:creator] do
    name { FFaker::Name.unique.name }
    email { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
  end
end
