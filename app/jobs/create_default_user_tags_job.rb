class CreateDefaultUserTagsJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(user_id)
    user = User.find(user_id)

    # Create default tags for the user
    Tag::USER_DEFAULT_TAGS.each do |tag_name|
      user.tags.find_or_create_by(name: tag_name, can_delete: false)
    end
  end
end
