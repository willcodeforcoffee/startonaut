FactoryBot.define do
  factory :bookmark do
    url { "https://example.com" }
    title { "Example dot com" }
    description { "Test Description" }
    association :user

    trait :with_tags do
      after(:create) do |bookmark|
        bookmark.tags << create_list(:tag, 2, user: bookmark.user)
      end
    end
  end
end
