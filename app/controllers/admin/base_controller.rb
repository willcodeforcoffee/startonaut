module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private

    # Respond as if the route doesn't exist so non-admins can't discover the admin section
    def require_admin
      raise ActionController::RoutingError.new("Not Found") unless Current.user&.admin?
    end
  end
end
