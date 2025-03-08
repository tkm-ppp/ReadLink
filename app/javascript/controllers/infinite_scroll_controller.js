import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "entries", "sentinel" ]
  static values = { url: String, page: Number }

  connect() {
    this.pageValue = 2 // 初期ページを2に設定

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadMore();
        }
      });
    });

    observer.observe(this.sentinelTarget)
  }

  loadMore() {
    const url = `${this.urlValue}?page=${this.pageValue}`

    fetch(url)
    .then(response => response.text()) // レスポンス形式に合わせて変更
    .then(html => {
      this.entriesTarget.insertAdjacentHTML('beforeend', html)
      this.pageValue++
    })
    .catch(error => {
      console.error("Error loading more items:", error);
    });
   }
}