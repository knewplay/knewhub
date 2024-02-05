module Constraints
  class AdministratorRouteConstraint
    def matches?(request)
      @request = request
      administrator_signed_in?
    end

    private

    def current_administrator
      validate_session
      return unless @request.session[:administrator_id]

      @current_administrator ||= Administrator.find(@request.session[:administrator_id])
    end

    def administrator_signed_in?
      !!current_administrator
    end

    def validate_session
      return if @request.session[:administrator_expires_at].nil?

      @request.session[:administrator_id] = nil if @request.session[:administrator_expires_at] < Time.current
    end
  end
end
