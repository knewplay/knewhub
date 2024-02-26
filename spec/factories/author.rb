FactoryBot.define do
  factory :author do
    github_uid { '11222333' }
    github_username { 'author' }
    association :user

    trait :real do
      github_uid { '85654561' }
      github_username { 'jp524' }
      association :user, :second
    end
  end
end
