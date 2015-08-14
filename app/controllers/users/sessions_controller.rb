class Users::SessionsController < Devise::SessionsController
def new 
 cookies[:api_key] = "abcdefghijk"
 super
end

#def destroy
 #cookies[:sign_out] = "sign out"
#end 
end
