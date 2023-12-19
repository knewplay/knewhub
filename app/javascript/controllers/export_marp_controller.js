import { Controller } from "@hotwired/stimulus"
import { Marpit, Element } from "@marp-team/marpit"

export default class extends Controller {
  static targets = ["content"]

  static values = {
    markdown: String
  }

  connect() {
    // Create instance
    const marpit = new Marpit({
      container: new Element("swiper-container", { navigation: "true", pagination: "true", scrollbar: "true" }),
      slideContainer: new Element("swiper-slide")
    })

    // Render markdown
    const { html, css } = marpit.render(this.markdownValue)
  
    // Use output in HTML
    const htmlFile = `
    <!DOCTYPE html>
    <html><body>
      <style>${css}</style>
      ${html}
    </body></html>
    `
    this.contentTarget.innerHTML = htmlFile
  }
}
