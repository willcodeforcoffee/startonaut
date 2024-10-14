FactoryBot.define do
  factory :user do
    email_address { "test@example.com" }
    password { "$TestPassword123" }
    password_confirmation { "$TestPassword123" }
  end
end
