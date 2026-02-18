class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :ensure_development_host if Rails.env.development?

  default_form_builder ThemedFormBuilder

  private

  def ensure_development_host
    return unless Rails.env.development?
    return if request.host_with_port == "startonaut.localhost:6250"

    redirect_to(
      "#{request.protocol}startonaut.localhost:6250#{request.fullpath}",
      allow_other_host: true,
      status: :temporary_redirect
    )
  end
end
