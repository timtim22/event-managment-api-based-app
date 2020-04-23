class UserMailer < ApplicationMailer
    def verification_email(user)
        @user = user
        mail(to: @user.email, subject: "MyGo prototype 1")
    end
end
