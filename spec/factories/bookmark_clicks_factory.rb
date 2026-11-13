FactoryBot.define do
  factory :bookmark_click do
    clicked_at { Time.current }
    association :bookmark
  end
end
