FactoryBot.define do
  factory :repository do
    owner { 'user' }
    name { 'repo_name' }
    title { 'Test Repo' }
    association :author

    trait :real do
      owner { 'jp524' }
      name { 'test-repo' }
      title { 'Test Repo' }
      association :author, :real
    end
  end
end
