FactoryBot.define do
  factory :bookmark do
    url { "https://example.com" }
    title { "Example dot com" }
    description { "Test Description" }
    user { association(:user) }
  end
end
