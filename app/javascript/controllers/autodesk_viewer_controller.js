import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['viewerDiv', 'displayBtn', 'hideBtn']
  
  static values = {
    urn: String
  }

  viewer
  options = {
    env: 'AutodeskProduction',
    api: 'derivativeV2',
    getAccessToken: function (onTokenReady) {
      // Change line below to variable later
      const token = ''
      const timeInSeconds = 3600
      onTokenReady(token, timeInSeconds)
    }
  }

  documentId = 'urn:' + this.urnValue

  connect () {
    this.createViewer()
  }

  createViewer () {
    Autodesk.Viewing.Initializer(this.options, () => {
      this.viewer = new Autodesk.Viewing.GuiViewer3D(this.viewerDivTarget)
      const startedCode = this.viewer.start()
      if (startedCode > 0) {
        console.error('Failed to create a Viewer: WebGL not supported.')
        return
      }
      console.log('Initialization complete, loading a model next...')
      this.displayBtnTarget.classList.add('hide')
    })

    this.loadDocument()
  }

  loadDocument () {
    const onDocumentLoadSuccess = (viewerDocument) => {
      const defaultModel = viewerDocument.getRoot().getDefaultGeometry()
      this.viewer.loadDocumentNode(viewerDocument, defaultModel)
    }

    const onDocumentLoadFailure = (viewerErrorCode) => {
      console.error('Failed fetching Forge manifest. Error code: ' + viewerErrorCode)
    }

    Autodesk.Viewing.Document.load(this.documentId, onDocumentLoadSuccess, onDocumentLoadFailure)
  }

  display () {
    this.hideBtnTarget.classList.remove('hide')
    this.displayBtnTarget.classList.add('hide')
    this.createViewer()
  }

  hide () {
    this.displayBtnTarget.classList.remove('hide')
    this.hideBtnTarget.classList.add('hide')
    this.destroyViewer()
  }

  destroyViewer () {
    this.viewer.finish()
    this.viewer = null
    Autodesk.Viewing.shutdown()
  }
}
