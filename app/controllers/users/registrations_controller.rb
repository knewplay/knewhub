module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    # Override method to render `edit_user_registration` when using Turbo Stream
    def after_update_path_for(resource)
      if sign_in_after_change_password?
        respond_to do |format|
          format.html { signed_in_root_path(resource) }
          format.turbo_stream { edit_user_registration_path }
        end
      else
        new_session_path(resource_name)
      end
    end
  end
end
