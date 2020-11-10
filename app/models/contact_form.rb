class ContactForm < MailForm::Base
    attribute :name,      :validate => true
    attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
    attribute :file,      :attachment => true
  
    attribute :message
    attribute :nickname,  :captcha  => true
  
    # Declare the e-mail headers. It accepts anything the mail method
    # in ActionMailer accepts.
    def headers
      {
        :subject => "Orgonize Media Contact Form",
        :to => "kamran.ali@mygo.io",
        :from => %("#{name}" <#{email}>)
      }
    end
  end