FactoryBot.define do
  factory :bookmark do
    url { "https://example.com" }
    title { "Example dot com" }
    description { "Test Description" }
    feed_url { nil }
    association :user

    trait :with_tags do
      after(:create) do |bookmark|
        bookmark.tags << create_list(:tag, 2, user: bookmark.user)
      end
    end

    trait :with_feed_url do
      feed_url { "#{url}/feed" }
    end

    trait :with_faker_url do
      url { Faker::Internet.url }
    end

    trait :with_feed_error do
      feed_url { "#{url}/feed" }
      feed_status { "error" }
      feed_failure_count { 3 }
      feed_error_message { "FeedFetchError: HTTP request failed" }
    end

    trait :feed_failing_once do
      feed_url { "#{url}/feed" }
      feed_failure_count { 1 }
    end
  end
end
