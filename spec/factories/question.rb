FactoryBot.define do
  factory :question do
    body { 'Is this is real question?' }
    tag { 'first' }
    page_path { 'article.md' }
    association :repository
  end
end
