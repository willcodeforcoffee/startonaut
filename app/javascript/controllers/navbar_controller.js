import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon", "menuButton"];

  connect() {
    // Initialize the menu state
    this.menuOpen = false;
  }

  toggleMenu() {
    this.menuOpen = !this.menuOpen;

    if (this.menuOpen) {
      this.showMobileMenu();
    } else {
      this.hideMobileMenu();
    }
  }

  showMobileMenu() {
    this.mobileMenuTarget.classList.remove("hidden");
    this.menuIconTarget.classList.add("hidden");
    this.closeIconTarget.classList.remove("hidden");
  }

  hideMobileMenu() {
    this.mobileMenuTarget.classList.add("hidden");
    this.menuIconTarget.classList.remove("hidden");
    this.closeIconTarget.classList.add("hidden");
  }

  // Close menu when clicking outside (optional enhancement)
  disconnect() {
    this.hideMobileMenu();
  }
}
