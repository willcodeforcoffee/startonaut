class ExportBookmarksController < ApplicationController
  def index
  end

  def show
    @bookmarks = Current.user.bookmarks.includes(:tags).order(created_at: :desc)

    html_content = generate_netscape_html(@bookmarks)

    send_data html_content,
              filename: "bookmarks.html",
              type: "text/html",
              disposition: "attachment"
  end

  private

  def generate_netscape_html(bookmarks)
    <<~HTML
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL>
        <p>
          #{bookmarks.map { |bookmark| bookmark_entry(bookmark) }.join("\n")}
        </p>
      </DL>
    HTML
  end

  def bookmark_entry(bookmark)
    tags = bookmark.tag_list_no_spaces
    description = bookmark.description.present? ? "<DD>#{CGI.escapeHTML(bookmark.description)}</DD>" : ""

    <<~ENTRY.strip
      <DT>
        <A HREF="#{CGI.escapeHTML(bookmark.url)}" ADD_DATE="#{bookmark.created_at.to_i}" TOREAD="0" PRIVATE="1" TAGS="#{CGI.escapeHTML(tags)}">#{CGI.escapeHTML(bookmark.title)}</A>
      </DT>
      #{description}
    ENTRY
  end
end
