import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "hiddenInput", "tagContainer"]
  static values = {
    url: String,
    selectedTags: Array
  }

  connect() {
    this.selectedTags = this.selectedTagsValue || []
    this.highlightedIndex = -1  // Track which dropdown item is highlighted
    this.renderSelectedTags()
    this.updateHiddenInput()
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 1) {
      this.hideDropdown()
      return
    }

    // Reset highlight when searching
    this.highlightedIndex = -1

    // Debounce the search
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const tags = await response.json()
        this.renderDropdown(tags, query)
      }
    } catch (error) {
      console.error('Tag search failed:', error)
    }
  }

  renderDropdown(tags, query) {
    // Filter out already selected tags
    const availableTags = tags.filter(tag =>
      !this.selectedTags.some(selected => selected.toLowerCase() === tag.name.toLowerCase())
    )

    this.dropdownItems = [] // Store items for keyboard navigation
    let html = ''

    // Show existing tags that match
    availableTags.forEach((tag, index) => {
      this.dropdownItems.push({ type: 'existing', name: tag.name })
      html += `
        <div class="px-3 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 dropdown-item"
             data-action="click->tags#selectExistingTag"
             data-tag-name="${tag.name}"
             data-index="${index}">
          ${this.escapeHtml(tag.name)}
        </div>
      `
    })

    // Show option to create new tag if it doesn't exist
    const exactMatch = availableTags.some(tag => tag.name.toLowerCase() === query.toLowerCase())
    if (!exactMatch && query.trim()) {
      const createIndex = availableTags.length
      this.dropdownItems.push({ type: 'create', name: query })
      html += `
        <div class="px-3 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 text-blue-600 dropdown-item"
             data-action="click->tags#createNewTag"
             data-tag-name="${query}"
             data-index="${createIndex}">
          <span class="font-medium">Create:</span> ${this.escapeHtml(query)}
        </div>
      `
    }

    this.dropdownTarget.innerHTML = html
    this.highlightedIndex = -1 // Reset highlight
    this.showDropdown()
  }

  selectExistingTag(event) {
    const tagName = event.currentTarget.dataset.tagName
    this.addTag(tagName)
  }

  createNewTag(event) {
    const tagName = event.currentTarget.dataset.tagName
    this.addTag(tagName)
  }

  addTag(tagName) {
    const normalizedName = tagName.trim()

    if (!normalizedName) return

    // Check if tag is already selected
    if (this.selectedTags.some(tag => tag.toLowerCase() === normalizedName.toLowerCase())) {
      return
    }

    this.selectedTags.push(normalizedName)
    this.renderSelectedTags()
    this.updateHiddenInput()
    this.clearInput()
    this.hideDropdown()
  }

  removeTag(event) {
    const tagName = event.params.tag
    this.selectedTags = this.selectedTags.filter(tag => tag !== tagName)
    this.renderSelectedTags()
    this.updateHiddenInput()
  }

  handleKeydown(event) {
    const dropdownVisible = !this.dropdownTarget.classList.contains('hidden')
    const hasItems = this.dropdownItems && this.dropdownItems.length > 0

    if (event.key === 'ArrowDown') {
      event.preventDefault()
      if (dropdownVisible && hasItems) {
        this.highlightedIndex = Math.min(this.highlightedIndex + 1, this.dropdownItems.length - 1)
        this.updateHighlight()
      }
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      if (dropdownVisible && hasItems) {
        this.highlightedIndex = Math.max(this.highlightedIndex - 1, -1)
        this.updateHighlight()
      }
    } else if (event.key === 'Tab') {
      if (dropdownVisible && hasItems) {
        // Only prevent default if dropdown is visible with items
        event.preventDefault()
        // Tab moves to next item in dropdown
        this.highlightedIndex = Math.min(this.highlightedIndex + 1, this.dropdownItems.length - 1)
        this.updateHighlight()
      }
      // If dropdown is not visible or empty, let Tab do its default behavior (move to next field)
    } else if (event.key === 'Enter') {
      event.preventDefault()

      if (dropdownVisible && hasItems && this.highlightedIndex >= 0) {
        // Select highlighted item
        const selectedItem = this.dropdownItems[this.highlightedIndex]
        this.addTag(selectedItem.name)
      } else {
        // Add current input as new tag if no item is highlighted
        const query = this.inputTarget.value.trim()
        if (query) {
          this.addTag(query)
        }
      }
    } else if (event.key === 'Escape') {
      this.hideDropdown()
      this.highlightedIndex = -1
    }
  }

  renderSelectedTags() {
    const html = this.selectedTags.map(tag => `
      <span class="inline-flex items-center gap-1 px-2 py-1 text-sm bg-blue-100 text-blue-800 rounded-md mr-2 mb-2">
        ${this.escapeHtml(tag)}
        <button type="button"
                class="ml-1 text-blue-600 hover:text-blue-800"
                data-action="click->tags#removeTag"
                data-tags-tag-param="${tag}">
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </span>
    `).join('')

    this.tagContainerTarget.innerHTML = html
  }

  updateHiddenInput() {
    this.hiddenInputTarget.value = this.selectedTags.join(',')
  }

  clearInput() {
    this.inputTarget.value = ''
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
    this.highlightedIndex = -1
  }

  updateHighlight() {
    const dropdownItems = this.dropdownTarget.querySelectorAll('.dropdown-item')

    // Remove previous highlights
    dropdownItems.forEach(item => {
      item.classList.remove('bg-blue-100')
    })

    // Highlight current item
    if (this.highlightedIndex >= 0 && dropdownItems[this.highlightedIndex]) {
      dropdownItems[this.highlightedIndex].classList.add('bg-blue-100')

      // Scroll into view if needed
      dropdownItems[this.highlightedIndex].scrollIntoView({
        block: 'nearest',
        behavior: 'smooth'
      })
    }
  }

  // Hide dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
