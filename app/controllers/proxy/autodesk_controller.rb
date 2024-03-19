module Proxy
  class AutodeskController < ApplicationController
    before_action :authenticate_user!

    def show
      autodesk_service = Autodesk.new
      response = autodesk_service.call_viewer(params[:request_type], params[:path], params[:format])

      head :bad_request and return unless response.status == 200

      send_data response.body
    end
  end
end
