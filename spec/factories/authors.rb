FactoryBot.define do
  factory :author do
    github_uid { '12345' }
    github_username { 'user' }
    association :user

    trait :real do
      github_uid { '85654561' }
      github_username { 'jp524' }
      association :user, :second
    end
  end
end
