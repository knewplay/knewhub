FactoryBot.define do
  factory :repository do
    name { 'repo_name' }
    title { 'Test Repo' }
    association :github_installation

    trait :real do
      name { 'test-repo' }
      title { 'Test Repo' }
      association :github_installation, :real
    end
  end
end
