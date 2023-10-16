FactoryBot.define do
  factory :answer do
    body { 'This is a proposed answer.' }
    association :question
    association :user, :second
  end
end
