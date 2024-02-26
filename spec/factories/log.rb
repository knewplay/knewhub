FactoryBot.define do
  factory :log do
    content { 'Some log content.' }
    association :build
  end
end
