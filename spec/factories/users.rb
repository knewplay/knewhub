FactoryBot.define do
  factory :user do
    email { 'email@example.com' }
    password { 'password' }
    confirmed_at { Time.current }

    trait :second do
      email { 'another.email@example.com' }
    end
  end
end
