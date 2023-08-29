FactoryBot.define do
  factory :user do
    email { 'email@example.com' }
    password { 'password' }
    confirmed_at { Time.now }
  end
end
