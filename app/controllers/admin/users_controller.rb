module Admin
  class UsersController < BaseController
    # GET /admin/users
    def index
      @users = User
        .select(
          "users.*",
          "(SELECT COUNT(*) FROM bookmarks WHERE bookmarks.user_id = users.id) AS bookmarks_count",
          "(SELECT COUNT(*) FROM tags WHERE tags.user_id = users.id) AS tags_count"
        )
        .order(Arel.sql("last_signed_in_at IS NULL, last_signed_in_at DESC, created_at DESC"))
    end
  end
end
