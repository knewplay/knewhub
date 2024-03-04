import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewerDiv"]

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
    })
  }
}
