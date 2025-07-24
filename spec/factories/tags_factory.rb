FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
    association :user
  end
end
