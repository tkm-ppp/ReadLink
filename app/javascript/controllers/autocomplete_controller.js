import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    console.log("Autocomplete Controller connected")
    this.inputTarget.setAttribute("autocomplete", "off")
  }

  async search() {
    const query = this.inputTarget.value;
    if (query.length < 2) {
      this.clearResults();
      return;
    }

    try {
      // APIエンドポイントを /libraries/autocomplete に変更
      const response = await fetch(`/libraries/autocomplete?term=${query}`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const libraries = await response.json();
      this.displayResults(libraries);
    } catch (error) {
      console.error("検索エラー:", error);
      this.clearResults();
    }
  }

  displayResults(libraries) {
    this.resultsTarget.innerHTML = "";
    if (libraries.length === 0) {
      this.resultsTarget.innerHTML = '<li class="p-2">一致する図書館はありません</li>';
      return;
    }

    const resultsList = document.createElement('ul');
    resultsList.classList.add("absolute", "z-10", "bg-white", "border", "border-gray-300", "rounded-md", "shadow-md", "mt-1", "w-full");

    libraries.forEach(library => {
      const listItem = document.createElement('li');
      listItem.classList.add("p-2", "hover:bg-gray-100", "cursor-pointer");
      listItem.textContent = library.text; //  library.name から library.text に変更 (autocompleteアクションのレスポンスに合わせる)
      listItem.addEventListener('click', () => {
        this.selectResult(library);
      });
      resultsList.appendChild(listItem);
    });
    this.resultsTarget.appendChild(resultsList);
  }

  clearResults() {
    this.resultsTarget.innerHTML = "";
  }

  selectResult(library) {
    this.inputTarget.value = library.text; // library.name から library.text に変更 (autocompleteアクションのレスポンスに合わせる)
    this.clearResults();
    console.log("選択された図書館:", library);
    // ここに候補選択後の処理を実装
  }
}