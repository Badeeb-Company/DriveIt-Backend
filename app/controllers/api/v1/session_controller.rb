module Api
	module V1
		class SessionController < BaseController
			skip_before_action :authenticate_user!, :except => [:logout]
			def_param_group :device  do 
				param :device, Hash, :required => true do
					param :device_id, String, :required => true
					param :fcm_token, String
					param :device_type, ["ios","and"], :required => true
				end
			end
			
			api :POST, "api/v1/driver", "Signup Driver"
			param_group :device
			param :driver, Hash, :required => true do
				param :email, "Email", :required => true
				param :username, String, :required => true
				param :image_url, "URL", :required => true
				param :password, String, :required => true
				param :name, "Name", :required => true
				param :lng, Float, :required => true
				param :lat, Float, :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"}, :driver => User.new(:user_type => User.user_types[:driver]).as_json(:auth => true)
			def signup_driver
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "api/v1/client", "Signup Client"
			param_group :device
			param :client, Hash, :required => true do
				param :email, "Email", :required => true
				param :username, String, :required => true
				param :image_url, "URL", :required => true
				param :password, String, :required => true
				param :name, "Name", :required => true
				param :lng, Float, :required => true
				param :lat, Float, :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"}, :client => User.new(:user_type => User.user_types[:client]).as_json(:auth => true)
			def signup_client
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "api/v1/driver/login", "Login Driver"
			param_group :device
			param :driver, Hash, :required => true do
				param :username, String, :required => true
				param :password, String, :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
			error STATUS_Unauthorized, "Username or password incorrect"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Login Completed"}, :client => User.new(:user_type => User.user_types[:client]).as_json(:auth => true)
			def login_driver
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "api/v1/cleint/login", "Login Client"
			param_group :device
			param :client, Hash, :required => true do
				param :username, String, :required => true
				param :password, String, :required => true
			end

			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
			error STATUS_Unauthorized, "Username or password incorrect"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Login Completed"}, :client => User.new(:user_type => User.user_types[:client]).as_json(:auth => true)
			def login_client
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end
			api :POST, "/api/v1/logout", "Logout User (driver/client)"
			param_group :device
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "User Logged Out"}
			def logout
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end
		end
	end
end
