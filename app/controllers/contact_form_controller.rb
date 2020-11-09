class ContactFormController < ApplicationController

    def send_email()
        #c = ContactForm.new(:name => 'José', :email => 'your@email.com')
        @contact = ContactForm.new(:name => params[:name], :email => params[:email], :message => params[:message], :subject => params[:subject])
        if @contact.deliver
            response = {
                "success"=> true,
                "message" => "Successfully sent."
            }.to_json

            render json: response
         
        else
            response = {
                "success"=> false,
                "message" => "Messae couln't be sent."
            }.to_json

            render json: response
        end
    end
    
end
