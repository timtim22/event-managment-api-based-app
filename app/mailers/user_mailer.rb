class UserMailer < ApplicationMailer
 
    def verification_email(user,url)
        @user = user
        @url = url
        mail(to: @user.email, subject: "MyGo")
    end

    # web dashboard api
    def send_verification_code(user,code)
      @user = user
      @code = code
      mail(to: @user.email, subject: 'MyGo User Verification')
    end

    def welcome_email(user)
      @user = user
      mail(to: @user.email, subject: 'Welcome to MyGo')
    end
end
