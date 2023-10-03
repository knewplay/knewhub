FactoryBot.define do
  factory :log do
    content { 'Some log content.' }
    step { 1 }
    association :build
  end
end
