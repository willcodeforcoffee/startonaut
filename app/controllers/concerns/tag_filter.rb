# Tag filtering via the "tags" query param, a comma-separated list of tag names,
# e.g. /pages?tags=ruby,rails shows only bookmarks tagged with both "ruby" and "rails".
module TagFilter
  extend ActiveSupport::Concern

  included do
    helper_method :selected_tag_names
  end

  private

  def selected_tag_names
    @selected_tag_names ||= params[:tags].to_s.split(",").map { it.strip.downcase }.reject(&:blank?).uniq
  end

  # The current user's tags in name order, each with a bookmarks_count attribute counting only the
  # given bookmarks, i.e. how many results there would be after adding that tag to the filter
  def tags_with_bookmark_counts(bookmarks)
    tags = Tag.arel_table
    bookmarks_tags = Arel::Table.new(:bookmarks_tags)
    matching_bookmarks = tags.join(bookmarks_tags, Arel::Nodes::OuterJoin).on(
      bookmarks_tags[:tag_id].eq(tags[:id]).and(bookmarks_tags[:bookmark_id].in(bookmarks.select(:id).arel))
    ).join_sources

    Current.user.tags
      .joins(matching_bookmarks)
      .group(:id)
      .select("tags.*, COUNT(bookmarks_tags.bookmark_id) AS bookmarks_count")
      .order(:name)
  end

  def group_tags_by_letter(tags)
    tags.group_by { |tag| tag.name.first.upcase }
  end
end
