module Proxy
  class AutodeskController < ApplicationController
    before_action :authenticate_user!

    # GET /autodesk/viewer-proxy/derivativeservice/v2/:request_type/*path
    def show
      autodesk_service = Autodesk.new
      response = autodesk_service.call_viewer(params[:request_type], params[:path], params[:format])

      head :bad_request and return unless response.status == 200

      send_data response.body
    end
  end
end
