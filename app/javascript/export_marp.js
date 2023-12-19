import { Marpit } from "@marp-team/marpit"

function exportMarp() {
  // Create instance
  const marpit = new Marpit()

  // Render markdown
  const markdown = `

  # Hello, Marpit!

  Marpit is the skinny framework for creating slide deck from Markdown.

  ---

  ## Ready to convert into PDF!

  You can convert into PDF slide deck through Chrome.

  `
  const { html, css } = marpit.render(markdown)

  // 4. Use output in your HTML
  const htmlFile = `
  <!DOCTYPE html>
  <html><body>
    <style>${css}</style>
    ${html}
  </body></html>
  `
  fs.writeFileSync('example.html', htmlFile.trim())
}

exportMarp();