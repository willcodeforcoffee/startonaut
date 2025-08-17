FactoryBot.define do
  factory :page do
    association :user
    title { "Test Page" }
    description { "This is a test page.\nLorem ipsum dolor sit amet." }
  end
end
