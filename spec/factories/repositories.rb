FactoryBot.define do
  factory :repository do
    name { 'repo_name' }
    token { 'ghp_abcde12345' }
    title { 'Test Repo' }
    association :author
  end
end
