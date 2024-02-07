module Users
  class RegistrationsController < Devise::RegistrationsController
    # Override method to redirect to root_path inside Turbo Frame.
    # Otherwise, "content missing" is displayed inside the Turbo Frame
    def destroy
      resource.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      redirect_after_destroy
    end

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

    private

    def redirect_after_destroy
      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, root_path) }
      end
    end
  end
end
