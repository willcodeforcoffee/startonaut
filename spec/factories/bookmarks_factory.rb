FactoryBot.define do
  factory :site_bookmark do
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
  end
end
