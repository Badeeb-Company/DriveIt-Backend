module Api
	module V1
		class SessionController < BaseController
			# skip_before_action :authenticate_user!#, :except => [:logout]
		#	skip_before_action :authenticate_driver!
			def_param_group :device  do 
				param :device, Hash, :required => true do
					param :device_id, String, :required => true
					param :fcm_token, String
					param :device_type, ["ios","and"], :required => true
				end
			end
			
			api :POST, "api/v1/driver", "Signup Driver"
			param :driver, Hash, :required => true do
				param :email, "Email", :required => true
				param :phone, "Phone", :required => true
				param :image_url, "URL", :required => true
				param :password, String, :required => true
				param :name, "Name", :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"}, :driver => Driver.new().as_json(:auth => true)
			def signup_driver
				@driver = Driver.new(driver_params)
				return render :status => STATUS_ERROR, :json => {:meta => {:status => STATUS_ERROR, :message => @driver.errors.full_messages.first}, :errors => @driver.errors.full_messages.first} unless @driver.save
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"},:driver => @driver.as_json(:auth => true)}
			end

			api :POST, "api/v1/client", "Signup Client"
			param :client, Hash, :required => true do
				param :email, "Email", :required => true
				param :phone, "Phone", :required => true
				param :image_url, "URL", :required => true
				param :password, String, :required => true
				param :name, "Name", :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"}, :client => User.new().as_json(:auth => true)
			def signup_client
				@user = User.new(user_params)
				return render :status => STATUS_ERROR, :json => {:meta => {:status => STATUS_ERROR, :message => @user.errors.full_messages.first}, :errors => @user.errors.full_messages.first} unless @user.save
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"},:user => @user.as_json(:auth => true)}
			end

			api :POST, "api/v1/driver/login", "Login Driver"
			param :driver, Hash, :required => true do
				param :email, "Email", :required => true
				param :password, String, :required => true
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
			error STATUS_Unauthorized, "Email or password incorrect"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Login Completed"}, :driver => Driver.new().as_json(:auth => true)
			def login_driver
				@driver = Driver.where(:email => params[:driver][:email]).first
				unless @driver.blank?
					if @driver.valid_password?(params[:driver][:password])
						sign_in("driver",@driver)
						return render :status => 200 ,:json=> {:meta => {:status=>200, :message => "Login Completed"}, :driver => @driver.as_json(:auth => true)}
					end
				end
				return render :status => STATUS_Unauthorized, :json => {:meta => {:status => STATUS_Unauthorized, :message => "Email or password incorrect"}}
			end

			api :POST, "api/v1/cleint/login", "Login Client"
			# param_group :device
			param :client, Hash, :required => true do
				param :email, "Email", :required => true
				param :password, String, :required => true
			end

			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
			error STATUS_Unauthorized, "Email or password incorrect"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Login Completed"}, :client => User.new().as_json(:auth => true)
			def login_client
				@user = User.where(:email => params[:client][:email]).first
				unless @user.blank?
					if @user.valid_password?(params[:client][:password])
						sign_in("user",@user)
						return render :status => 200 ,:json=> {:meta => {:status=>200, :message => "Login Completed"}, :client => @user.as_json(:auth => true)}
					end
				end
				return render :status => STATUS_Unauthorized, :json => {:meta => {:status => STATUS_Unauthorized, :message => "Email or password incorrect"}}
			end
			api :POST, "/api/v1/logout", "Logout User (driver/client)"
			# param_group :device
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "User Logged Out"}
			def logout
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end



			private 
				def user_params
					params[:client].permit(:email, :phone,:image_url,:password,:name)
				end

				def driver_params
					params[:driver].permit(:email, :phone,:image_url,:password,:name)
				end
		end
	end
end
