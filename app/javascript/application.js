// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from '@hotwired/turbo-rails'
import 'controllers'

import { far } from '@fortawesome/free-regular-svg-icons'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core'
import '@fortawesome/fontawesome-free'

import 'timezone'
import { register } from 'swiper/element/bundle'
library.add(far, fas, fab)
register()

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target)
}
