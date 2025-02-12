// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { Application } from "@hotwired/stimulus";
import ContentLoader from '@stimulus-components/content-loader'
import Sound from '@stimulus-components/sound'
import Dropdown from '@stimulus-components/dropdown'
import HelloController from "./controllers/hello_controller"
import Carousel from '@stimulus-components/carousel'

const application = Application.start()
const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))
application.register('content-loader', ContentLoader)
application.register('dropdown', Dropdown)
application.register("hello", HelloController)
application.register('sound', Sound)
application.register('carousel', Carousel)
application.debug = true

export default class extends Dropdown {
    connect() {
      super.connect()
      console.log("Do what you want here.")
    }
  
    toggle(event) {
      super.toggle()
    }
  
    hide(event) {
      super.hide(event)
    }
  }