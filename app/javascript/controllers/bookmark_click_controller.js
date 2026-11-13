import { Controller } from "@hotwired/stimulus"

// Records a bookmark click in the background without delaying the link opening
export default class extends Controller {
  static values = { url: String }

  track() {
    const data = new FormData()
    data.append("authenticity_token", document.querySelector("meta[name='csrf-token']")?.content)
    navigator.sendBeacon(this.urlValue, data)
  }
}
