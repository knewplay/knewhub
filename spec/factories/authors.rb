FactoryBot.define do
  factory :author do
    github_uid { '12345' }
    github_username { 'user' }
    installation_id { '12345678' }
    association :user

    trait :real do
      github_uid { '85654561' }
      github_username { 'jp524' }
      installation_id { '47087696' }
      association :user, :second
    end
  end
end
