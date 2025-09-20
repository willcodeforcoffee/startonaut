class UserMailer < ApplicationMailer
  default from: "welcome@startonaut.com"

  def welcome_email(user)
    @user = user
    @url = root_url
    mail(to: @user.email_address, subject: "Welcome to Startonaut!")
  end
end
