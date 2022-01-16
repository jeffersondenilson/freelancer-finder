FactoryBot.define do
  factory :proposal_refusal do
    refuse_reason { 'MyText' }
    proposal { nil }
  end
end
