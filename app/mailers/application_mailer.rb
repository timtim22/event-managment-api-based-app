class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@mygo.io'
  layout 'mailer'
end
