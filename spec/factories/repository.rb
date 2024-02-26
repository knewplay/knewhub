FactoryBot.define do
  factory :repository do
    name { 'repo_name' }
    title { 'Test Repo' }
    uid { 123_456_789 }
    association :github_installation

    trait :second do
      name { 'another_repo' }
      title { 'Another Repo' }
      uid { 111_222_333 }
    end

    trait :real do
      name { 'test-repo' }
      title { 'Test Repo' }
      uid { 663_068_537 }
      association :github_installation, :real
    end
  end
end
