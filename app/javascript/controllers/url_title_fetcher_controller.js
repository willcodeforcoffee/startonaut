import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="url-title-fetcher"
export default class extends Controller {
  static targets = ["url", "title"];
  static debounceTimeouts = new Map();

  connect() {
    // Add event listener to URL field
    this.urlTarget.addEventListener("input", this.handleUrlInput.bind(this));
  }

  disconnect() {
    // Clean up any pending timeouts
    const timeoutId = this.constructor.debounceTimeouts.get(this.element);
    if (timeoutId) {
      clearTimeout(timeoutId);
      this.constructor.debounceTimeouts.delete(this.element);
    }
  }

  handleUrlInput(event) {
    const url = event.target.value.trim();

    // Clear any existing timeout for this controller
    const existingTimeout = this.constructor.debounceTimeouts.get(this.element);
    if (existingTimeout) {
      clearTimeout(existingTimeout);
    }

    // Don't fetch if URL is empty or title already has content
    if (!url || this.titleTarget.value.trim()) {
      return;
    }

    // Debounce the fetch request
    const timeoutId = setTimeout(() => {
      this.fetchUrlTitle(url);
      this.constructor.debounceTimeouts.delete(this.element);
    }, 1000); // Wait 1 second after user stops typing

    this.constructor.debounceTimeouts.set(this.element, timeoutId);
  }

  async fetchUrlTitle(url) {
    // Basic URL validation
    if (!this.isValidUrl(url)) {
      return;
    }

    try {
      // Show loading state
      this.setLoadingState(true);

      // Fetch the URL content
      const response = await fetch(
        `/bookmarks/fetch_title?url=${encodeURIComponent(url)}`,
        {
          method: "GET",
          headers: {
            Accept: "application/json",
            "X-Requested-With": "XMLHttpRequest",
          },
        }
      );

      console.log("Fetch response:", response);

      if (response.ok) {
        const data = await response.json();
        if (data.title && !this.titleTarget.value.trim()) {
          this.titleTarget.value = data.title;
          this.titleTarget.dispatchEvent(new Event("input", { bubbles: true }));
        }
      }
    } catch (error) {
      console.log("Failed to fetch URL title:", error);
    } finally {
      this.setLoadingState(false);
    }
  }

  isValidUrl(string) {
    try {
      const url = new URL(string);
      return url.protocol === "http:" || url.protocol === "https:";
    } catch (_) {
      return false;
    }
  }

  setLoadingState(loading) {
    if (loading) {
      this.titleTarget.placeholder = "Fetching title...";
      this.titleTarget.style.opacity = "0.7";
    } else {
      this.titleTarget.placeholder = "";
      this.titleTarget.style.opacity = "1";
    }
  }
}
