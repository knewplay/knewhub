FactoryBot.define do
  factory :github_installation do
    uid { '44555666' }
    username { 'repo_owner' }
    installation_id { '12345678' }
    association :author

    trait :real do
      uid { '85654561' }
      username { 'jp524' }
      installation_id { '47766910' }
      association :author, :real
    end

    trait :real_additional do
      uid { '120281562' }
      username { 'knewplay' }
      installation_id { '47356899' }
      association :author, :real
    end
  end
end
