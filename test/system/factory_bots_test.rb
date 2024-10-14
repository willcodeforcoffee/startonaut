require "application_system_test_case"

class FactoryBotsTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit factory_bots_url
  #
  #   assert_selector "h1", text: "FactoryBot"
  # end

  FactoryBot.factories.map(&:name).each do |factory_name|
    test "#{factory_name} factory creates a valid object" do
      o = FactoryBot.build(factory_name)
      assert o.valid?
    end
  end
end
