FactoryBot.define do
  factory :repository do
    name { 'repo_name' }
    token { 'ghp_abcde12345' }
    title { 'Test Repo' }
    association :author

    trait :real do
      name { 'test-repo' }
      token { Rails.application.credentials.pat }
      title { 'Test Repo' }
      association :author, :real
    end
  end
end
