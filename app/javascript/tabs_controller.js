import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab", "content" ]

  switch(event) {
    const index = event.target.dataset.tabIndex;
    this.tabTargets.forEach(tab => {
      tab.classList.toggle("active", tab.dataset.tabIndex === index); // active クラスでアクティブなタブを視覚的に表現
    });
    this.contentTargets.forEach(content => {
      content.classList.toggle("hidden", content.dataset.tabIndex !== index);
    });
  }
}