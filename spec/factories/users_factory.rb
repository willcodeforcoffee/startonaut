FactoryBot.define do
  factory :user do
    email_address { "test@example.com" }
    password { "Password123" }
    password_confirmation { "Password123" }
    # password_digest { BCrypt::Password.create("password") }

    trait :with_faker_email do
      email_address { Faker::Internet.email }
    end

    after(:create) { |user, context| CreateDefaultUserTagsJob.new.perform(user.id) }
  end
end
