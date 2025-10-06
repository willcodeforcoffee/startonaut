# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a test user in development environment when no other users exist
if Rails.env.development? && !User.any?
  test_user = User.find_by(email_address: "test@example.com")
  test_user = User.create(email_address: "test@example.com", password: "Password123", password_confirmation: "Password123") if test_user.blank?
end
