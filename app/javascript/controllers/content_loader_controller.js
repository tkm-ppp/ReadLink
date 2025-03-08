import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "loader", "content" ]

  connect() {
    this.showLoader()
  }

  showLoader() {
    this.loaderTarget.classList.remove("hidden")
    this.contentTarget.classList.add("hidden")
  }

  hideLoader() {
    this.loaderTarget.classList.add("hidden")
    this.contentTarget.classList.remove("hidden")
  }
}