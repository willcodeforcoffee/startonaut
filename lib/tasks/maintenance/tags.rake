namespace :maintenance do
  namespace :tags do
    desc "Setup default tags for all users"
    task setup: :environment do
      User.find_each do |user|
        puts "Setting up default tags for user #{user.id}"
        CreateDefaultUserTagsJob.perform_now(user.id)
      end

      puts "Finished successfully.\n"
    end

    desc "Mark default tags as non-deletable"
    task mark_non_deletable: :environment do
      Tag.all.each do |tag|
        tag.update(can_delete: !Tag::USER_DEFAULT_TAGS.include?(tag.name))
      end

      puts "Finished successfully.\n"
    end
  end
end
