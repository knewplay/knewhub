FactoryBot.define do
  factory :build do
    status { 'In progress' }
    action { 'create' }
    association :repository
  end
end
