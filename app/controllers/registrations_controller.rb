class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }
  before_action :redirect_unless_feature_enabled

  # Show registration form
  def new
    @user = User.new
  end

  # Handle registration
  def create
    @user = User.new(user_params)

    if @user.save
      # Send welcome email
      UserMailer.welcome_email(@user).deliver_now

      # Redirect to success page
      redirect_to registration_success_path, notice: "Registration successful! Please check your email for a welcome message."
    else
      # Re-render form with errors
      render :new, status: :unprocessable_entity
    end
  end

  # Show success page
  def success
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def redirect_unless_feature_enabled
    unless FeatureFlag.enable_new_user_registration?
      redirect_to new_session_path, alert: "New user registrations are currently disabled."
    end
  end
end
