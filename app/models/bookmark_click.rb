class BookmarkClick < ApplicationRecord
  belongs_to :bookmark

  before_validation { self.clicked_at ||= Time.current }
end
