module Constraints
  class AdministratorRouteConstraint
    def matches?(request)
      administrator_signed_in?(request)
    end

    private

    def current_administrator(request)
      validate_session(request)
      if request.session[:administrator_id]
        @current_administrator ||= Administrator.find(request.session[:administrator_id])
      end
    end

    def administrator_signed_in?(request)
      !!current_administrator(request)
    end

    def validate_session(request)
      return if request.session[:administrator_expires_at].nil?

      request.session[:administrator_id] = nil if request.session[:administrator_expires_at] < Time.current
    end
  end
end
