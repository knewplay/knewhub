import { Controller } from '@hotwired/stimulus'
import * as WebAuthnJSON from '@github/webauthn-json'
import { FetchRequest } from '@rails/request.js'

export default class extends Controller {
  static values = { callback: String }

  auth (event) {
    const [data, ,] = event.detail
    const _this = this

    WebAuthnJSON.get({ publicKey: data }).then(async function (credential) {
      const request = new FetchRequest('post', _this.callbackValue, { body: JSON.stringify(credential) })
      const response = await request.perform()

      if (response.ok) {
        const data = await response.json
        window.Turbo.visit(data.redirect, { action: 'replace' })
      } else {
        console.log('Something is wrong', response)
      }
    }).catch(function (error) {
      console.log('Something is wrong', error)
    })
  }

  error (event) {
    console.log('Something is wrong', event)
  }
}
