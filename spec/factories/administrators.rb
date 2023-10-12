FactoryBot.define do
  factory :administrator do
    name { 'admin' }
    password { 'password' }
    permissions { 'admin' }
  end
end
