class PasswordResetMailer < ApplicationMailer

  def password_reset_email(user,url)
    @user = user
    @url = url
    mail(to: @user.email, subject: "MyGo")
end
end
