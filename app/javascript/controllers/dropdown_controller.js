import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    // Close dropdown when clicking outside
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this);
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open();
    } else {
      this.close();
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden");
    document.addEventListener("click", this.boundCloseOnOutsideClick);
  }

  close() {
    this.menuTarget.classList.add("hidden");
    document.removeEventListener("click", this.boundCloseOnOutsideClick);
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseOnOutsideClick);
  }
}
