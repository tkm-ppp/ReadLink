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



