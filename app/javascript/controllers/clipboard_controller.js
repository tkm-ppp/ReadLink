import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}
export default class extends Controller {
  static targets = [ "source" ]
}