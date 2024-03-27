class ErrorsController < ApplicationController
  layout 'errors'

  # GET /404
  def not_found
    render status: :not_found
  end

  # GET /500
  def internal_server_error
    render status: :internal_server_error
  end
end
