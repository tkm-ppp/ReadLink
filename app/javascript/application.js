import "@hotwired/turbo-rails"
import "./controllers" // Stimulus controllers の読み込み
import { Application } from "@hotwired/stimulus";
import ContentLoader from '@stimulus-components/content-loader'
import Sound from '@stimulus-components/sound'
import Carousel from '@stimulus-components/carousel'
import Dropdown from "@stimulus-components/dropdown"
import Clipboard from '@stimulus-components/clipboard'
import ColorPicker from '@stimulus-components/color-picker'

const application = Application.start()

// Stimulus Components の登録

application.register('content-loader', ContentLoader)
application.register('sound', Sound)
application.register('carousel', Carousel)
application.register('dropdown', Dropdown)
application.register('clipboard', Clipboard)
application.register('color-picker', ColorPicker)


import '@simonwep/pickr/dist/themes/classic.min.css'
