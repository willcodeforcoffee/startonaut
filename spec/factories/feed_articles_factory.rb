FactoryBot.define do
  factory :feed_article do
    sequence(:guid) { |n| "guid-#{n}" }
    sequence(:url) { |n| "https://example.com/article-#{n}" }
    title { "Example Article" }
    description { "Article description" }
    published_at { 1.day.ago }
    association :bookmark
  end
end
