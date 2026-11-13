module ApplicationHelper
  # Render a datetime in UTC that local_time_controller.js converts to the viewer's time zone.
  # Clicking the time toggles between local time and UTC.
  def local_time_tag(datetime)
    return nil unless datetime

    utc = datetime.utc
    tag.time utc.strftime("%Y-%m-%d %H:%M UTC"),
      datetime: utc.iso8601,
      title: "Click to switch between local time and UTC",
      role: "button",
      tabindex: 0,
      class: "underline decoration-dashed underline-offset-4 cursor-pointer",
      data: {
        controller: "local-time",
        action: "click->local-time#toggle keydown.enter->local-time#toggle keydown.space->local-time#toggle:prevent"
      }
  end
end
