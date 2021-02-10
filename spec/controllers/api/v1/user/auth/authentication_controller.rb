require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::Users::Auth::AuthenticationController, type: :controller do
  describe "Mobile - Authentication API - " do

    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

###################################################################################################

    it "should login" do
      post :login, params: {uuid: mobile_users.last.uuid, device_token: "anything"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return all users" do
      post :get_accounts, params: {phone_number: User.last.phone_number}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should logout the users" do
      post :logout, params: {phone_number: User.last.phone_number}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should logout the users" do
      post :logout, params: {phone_number: User.last.phone_number}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
    # it "should return login details to business user" do
    #   post :login, params: {uuid: business_users.last, device_token: "firebase_device_token"}
      # should check the following
      #1. Key existence check
      #2. type check
      #3. null check
      #4. empty check
      # expect(response).to have_http_status(200)
      # expect(JSON.parse(response.body)["success"]).to eq(true)
      # expect(JSON.parse(response.body)["data"]).to have_key("token")
      # expect(JSON.parse(response.body)["data"]).to have_key("user")
      # expect(JSON.parse(response.body)["data"]["token"]).to be_a_kind_of(String)
      # expect(JSON.parse(response.body)['data']['token']).to_not be_a_kind_of(NilClass)
      # expect(JSON.parse(response.body)["data"]["token"]).to_not be_empty
      
      # #user object key existenc check
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("id")
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("profile_name")
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("avatar")
      # expect(JSON.parse(response.body)["data"]["user"]["avatar"]).to have_key("url")
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("phone_number")
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("email")
      # expect(JSON.parse(response.body)["data"]["user"]).to have_key("app_user")
      #  #user object type check
      #  expect(JSON.parse(response.body)["data"]["user"]["id"]).to be_a_kind_of(Integer)
      #  expect(JSON.parse(response.body)["data"]["user"]["profile_name"]).to be_a_kind_of(String) 
      #  expect(JSON.parse(response.body)["data"]["user"]["avatar"]).to be_a_kind_of(Hash) 
      #  expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to be_a_kind_of(String) 
      #  expect(JSON.parse(response.body)["data"]["user"]["email"]).to be_a_kind_of(String) 
      #  expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass) 

      # #user object nil check
      # expect(JSON.parse(response.body)["data"]["user"]["id"]).to_not be_a_kind_of(NilClass)
      # expect(JSON.parse(response.body)["data"]["user"]["profile_name"]).to_not be_a_kind_of(NilClass) 
      # expect(JSON.parse(response.body)["data"]["user"]["avatar"]["url"]).to_not be_a_kind_of(NilClass) 
      # expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to_not be_a_kind_of(NilClass) 
      # expect(JSON.parse(response.body)["data"]["user"]["email"]).to_not be_a_kind_of(NilClass) 
      # expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to_not be_a_kind_of(NilClass)

      # #user object emtpy check
      # expect(JSON.parse(response.body)["data"]["user"]["id"]).to_not eq("")
      # expect(JSON.parse(response.body)["data"]["user"]["profile_name"]).to_not eq("")
      # expect(JSON.parse(response.body)["data"]["user"]["avatar"]["url"]).to_not eq("")
      # expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to_not eq("")
      # expect(JSON.parse(response.body)["data"]["user"]["email"]).to_not eq("") 
      # expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to_not eq("")
    # end

##################################################################################################
    # it "should return login details to Normal user" do
    #   post :login, params: {id: mobile_users.last, device_token: "firebase_device_token"}
    #   # should check the following
    #   #1. Key existence check
    #   #2. type check
    #   #3. null check
    #   #4. empty check
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    #   expect(JSON.parse(response.body)["data"]).to have_key("token")
    #   expect(JSON.parse(response.body)["data"]["token"]).to be_a_kind_of(String)
    #   expect(JSON.parse(response.body)['data']['token']).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["token"]).to_not be_empty
    #   expect(JSON.parse(response.body)["data"]).to have_key("user")
    #   #user object key existenc check
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("id")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("first_name")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("last_name")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("avatar")
    #   expect(JSON.parse(response.body)["data"]["user"]["avatar"]).to have_key("url")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("phone_number")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("email")
    #   expect(JSON.parse(response.body)["data"]["user"]).to have_key("app_user")
    #    #user object type check
    #    expect(JSON.parse(response.body)["data"]["user"]["id"]).to be_a_kind_of(Integer)
    #    expect(JSON.parse(response.body)["data"]["user"]["first_name"]).to be_a_kind_of(String)
    #    expect(JSON.parse(response.body)["data"]["user"]["last_name"]).to be_a_kind_of(String)  
    #    expect(JSON.parse(response.body)["data"]["user"]["avatar"]).to be_a_kind_of(Hash) 
    #    expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to be_a_kind_of(String) 
    #    expect(JSON.parse(response.body)["data"]["user"]["email"]).to be_a_kind_of(String) 
    #    expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass) 

    #   #user object nil check
    #   expect(JSON.parse(response.body)["data"]["user"]["id"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["user"]["first_name"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["user"]["last_name"]).to_not be_a_kind_of(NilClass)  
    #   expect(JSON.parse(response.body)["data"]["user"]["avatar"]["url"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["user"]["email"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to_not be_a_kind_of(NilClass)

    #   #user object emtpy check
    #   expect(JSON.parse(response.body)["data"]["user"]["id"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["user"]["first_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["user"]["last_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["user"]["avatar"]["url"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["user"]["phone_number"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["user"]["email"]).to_not eq("") 
    #   expect(JSON.parse(response.body)["data"]["user"]["app_user"]).to_not eq("")
    
    # end

####################################################################################################
    # it "should return accounts registered against a phone number" do
    #   post :get_accounts, params: {phone_number: mobile_users.last.phone_number}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    #   #business
    #   #response object key existenc check
    #   expect(JSON.parse(response.body)["data"]).to have_key("accounts")
    #   expect(JSON.parse(response.body)["data"]["accounts"]).to have_key("business")
    #   expect(JSON.parse(response.body)["data"]["accounts"]).to have_key("app")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("id")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("profile_name")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("avatar")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["avatar"]).to have_key("url")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("phone_number")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("email")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]).to have_key("app_user")
    #   #app
    #   #response object key existenc check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("id")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("first_name")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("last_name")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("avatar")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["avatar"]).to have_key("url")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("phone_number")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("email")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]).to have_key("app_user")

    #   # business
    #   #response object type check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["id"]).to be_a_kind_of(Integer)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["profile_name"]).to be_a_kind_of(String)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["avatar"]).to be_a_kind_of(Hash) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["phone_number"]).to be_a_kind_of(String) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["email"]).to be_a_kind_of(String) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["app_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["web_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass)  

    #   # app
    #   #response object type check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["id"]).to be_a_kind_of(Integer)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["first_name"]).to be_a_kind_of(String)
    #   expect(JSON.parse(response.body)["data"]["user"]["last_name"]).to be_a_kind_of(String)  
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["avatar"]).to be_a_kind_of(Hash) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["phone_number"]).to be_a_kind_of(String) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["email"]).to be_a_kind_of(String) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["app_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["web_user"]).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass) 
      
    #   #business
    #   # response object nil check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["id"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["profile_name"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["last_name"]).to_not be_a_kind_of(NilClass)  
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["avatar"]["url"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["phone_number"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["email"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["app_user"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["web_user"]).to_not be_a_kind_of(NilClass)

    #   #app
    #   # response object nil check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["id"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["first_name"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["last_name"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["last_name"]).to_not be_a_kind_of(NilClass)  
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["avatar"]["url"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["phone_number"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["email"]).to_not be_a_kind_of(NilClass) 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["app_user"]).to_not be_a_kind_of(NilClass)
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["web_user"]).to_not be_a_kind_of(NilClass)

    #   #business
    #   #response object emtpy check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["id"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["profile_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["last_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["avatar"]["url"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["phone_number"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["email"]).to_not eq("") 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["app_user"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["business"]["web_user"]).to_not eq("")

    #   #app
    #   #response object emtpy check
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["id"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["profile_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["last_name"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["avatar"]["url"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["phone_number"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["email"]).to_not eq("") 
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["app_user"]).to_not eq("")
    #   expect(JSON.parse(response.body)["data"]["accounts"]["app"]["web_user"]).to_not eq("")

    # end

    # it "should logout user and clear push token from pubnub push channel" do
    #   post :logout
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

    # # it "should verify code" do
    # #   post :verify_code, params: {email: "priboy@gmail.co", verification_code: "asdsda"}
    # #   # expect(response).to have_http_status(200)
    # #   # expect(subject).to render_template("user_mailer/verifciation_redirect_page")
    # #   expect(view).to render_template("user_mailer/verifciation_redirect_page")
    # # end

    # it "should update password" do
    #   post :update_password, params: {email: mobile_users.last.email, password: "asdasd"}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

  end
end
