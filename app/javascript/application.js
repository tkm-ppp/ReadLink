import "@hotwired/turbo-rails"
import "./controllers" // Stimulus controllers の読み込み
import { Application } from "@hotwired/stimulus";
import ContentLoader from '@stimulus-components/content-loader'
import Carousel from '@stimulus-components/carousel'
import { Autocomplete } from 'stimulus-autocomplete'


const application = Application.start()

// Stimulus Components の登録

application.register('content-loader', ContentLoader)
application.register('sound', Sound)
application.register('carousel', Carousel)
application.register('autocomplete', Autocomplete)



document.addEventListener('turbolinks:load', () => {
  // 市町村全選択チェックボックスの処理
  document.querySelectorAll('.city-select-all').forEach(checkbox => {
    const city = checkbox.dataset.city;
    checkbox.addEventListener('change', () => {
      document.querySelectorAll(`[data-city="${city}"].library-checkbox`).forEach(libCheckbox => {
        libCheckbox.checked = checkbox.checked;
      });
    });
  });
});
