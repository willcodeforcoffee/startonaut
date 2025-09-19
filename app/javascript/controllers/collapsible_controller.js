import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "toggleButton", "chevron"];

  toggle() {
    this.contentTarget.classList.toggle("hidden");
    this.chevronTarget.classList.toggle("rotate-180");
  }
}
