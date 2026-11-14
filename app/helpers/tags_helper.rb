module TagsHelper
  # Path to the current page filtered by the given tag names, keeping any search query
  def tag_filter_path(names)
    url_for(q: params[:q].presence, tags: names.join(",").presence, only_path: true)
  end

  # Path that adds the tag to the current filter, or removes it if it's already selected
  def toggle_tag_filter_path(name)
    names = selected_tag_names.include?(name) ? selected_tag_names - [ name ] : selected_tag_names + [ name ]
    tag_filter_path(names)
  end

  def tag_filter_link_classes(name, size: "px-2 py-1 text-xs")
    state = if selected_tag_names.include?(name)
      "bg-bright-turquoise-300 text-rich-black-900 hover:bg-bright-turquoise-200"
    else
      "bg-gray-100 hover:bg-bright-turquoise-100 text-gray-700 hover:text-bright-turquoise-800"
    end
    "inline-flex items-center #{size} rounded-full transition-colors #{state}"
  end
end
