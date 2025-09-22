FactoryBot.define do
  factory :user do
    email_address { "test@example.com" }
    password { "Password123" }
    password_confirmation { "Password123" }
    # password_digest { BCrypt::Password.create("password") }

    trait :with_faker_email do
      email_address { Faker::Internet.email }
    end
  end
end
