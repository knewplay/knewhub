FactoryBot.define do
  factory :github_installation do
    uid { '12345' }
    username { 'user' }
    installation_id { '12345678' }
    association :author

    trait :github_installation do
      uid { '85654561' }
      username { 'jp524' }
      installation_id { '47264231' }
      association :author, :real
    end
  end
end
