import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewerDiv", "displayBtn", "hideBtn"]

  viewer
  options = {
    env: 'AutodeskProduction2',
    api: 'streamingV2',
    getAccessToken: function(onTokenReady) {
        var token = 'YOUR_ACCESS_TOKEN'
        var timeInSeconds = 3600
        onTokenReady(token, timeInSeconds)
    }
  }
  
  connect() {
    Autodesk.Viewing.Initializer(this.options, () => {
      this.viewer = new Autodesk.Viewing.GuiViewer3D(this.viewerDivTarget)
      var startedCode = this.viewer.start()
      if (startedCode > 0) {
          console.error('Failed to create a Viewer: WebGL not supported.')
          return
      }
      console.log('Initialization complete, loading a model next...')
      this.displayBtnTarget.classList.add("hide")
    })
  }

  display() {
    this.hideBtnTarget.classList.remove("hide")
    this.displayBtnTarget.classList.add("hide")
    this.createViewer()
  }

  hide() {
    this.displayBtnTarget.classList.remove("hide")
    this.hideBtnTarget.classList.add("hide")
    this.destroyViewer()
  }

  createViewer() {
    this.viewer = new Autodesk.Viewing.GuiViewer3D(this.viewerDivTarget, {});
  }

  destroyViewer() {
    this.viewer.finish()
    this.viewer = null
    Autodesk.Viewing.shutdown()
  }
}
