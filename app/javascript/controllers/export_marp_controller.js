import { Controller } from '@hotwired/stimulus'
import { Marpit, Element } from '@marp-team/marpit'

export default class extends Controller {
  static targets = ['content']

  static values = {
    markdown: String
  }

  connect () {
    const marpit = new Marpit({
      container: new Element('swiper-container', {
        navigation: 'true',
        pagination: 'true',
        'pagination-clickable': 'true',
        keyboard: 'true'
      }),
      slideContainer: [
        new Element('swiper-slide'),
        new Element('div', { class: 'marp-slide' })
      ]
    })

    const { html } = marpit.render(this.markdownValue)

    this.contentTarget.innerHTML = html
  }
}
