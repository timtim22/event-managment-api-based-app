class AuthenticationController < ApplicationController
	  validates :password, :presence => true,
                       :confirmation => true,
                       :on => :update_password,
                       :length => {:within => 8..40},
                       :format => {message: 'should contain at least one lower character and a special character.', with: /\A(?=.*[a-z])(?=.*[[:^alnum:]]) /x}
end
