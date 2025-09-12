FactoryBot.define do
  factory :log do
    loggable { nil }
    level { "MyString" }
    message { "MyText" }
  end
end
