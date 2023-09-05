FactoryBot.define do
  factory :build do
    status { 'Created' }
    association :repository
  end
end
