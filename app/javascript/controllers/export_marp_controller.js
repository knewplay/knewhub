import { Controller } from "@hotwired/stimulus"
import { Marpit } from "@marp-team/marpit"

export default class extends Controller {
  static targets = ['content']

  static values = {
    markdown: String
  }

  connect() {
    // Create instance
    const marpit = new Marpit()

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
