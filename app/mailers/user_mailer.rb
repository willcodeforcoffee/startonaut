class UserMailer < ApplicationMailer
  default from: "welcome@startonaut.com"
  WELCOME_SUBJECT = "Welcome to Startonaut!"

  def welcome_email(user)
    return unless FeatureFlag.enable_user_mailer?

    @user = user
    @url = root_url
    mail(to: @user.email_address, subject: WELCOME_SUBJECT)
  end
end
