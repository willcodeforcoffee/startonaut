import { Controller } from "@hotwired/stimulus";

// Converts a server-rendered UTC <time> element to the viewer's local time zone.
// Clicking toggles between local time and UTC.
export default class extends Controller {
  connect() {
    this.date = new Date(this.element.getAttribute("datetime"));
    if (isNaN(this.date)) return;

    this.showingUtc = false;
    this.render();
  }

  toggle() {
    if (isNaN(this.date)) return;

    this.showingUtc = !this.showingUtc;
    this.render();
  }

  render() {
    this.element.textContent = this.showingUtc ? this.format("UTC") : this.format();
  }

  // Formats as "YYYY-MM-DD HH:MM TZ", in the given time zone or the browser's own
  format(timeZone) {
    const parts = new Intl.DateTimeFormat("en-US", {
      timeZone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      hourCycle: "h23",
      timeZoneName: "short"
    }).formatToParts(this.date);
    const part = (type) => parts.find((p) => p.type === type)?.value;

    return `${part("year")}-${part("month")}-${part("day")} ${part("hour")}:${part("minute")} ${part("timeZoneName")}`;
  }
}
