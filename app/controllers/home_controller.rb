class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    return redirect_to pages_path if authenticated?

    render :index
  end

  def theme
    raise ActionController::RoutingError.new("Not Found") unless Rails.env.development?
  end
end
