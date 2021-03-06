module Api
	module V1
		class SessionController < BaseController
			
		STATUS_UNAUTHORIZED = "401"

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
				param :name, String, :required => true
				param :driver_type, ["CAR","BIKE"]
			end
			error STATUS_BAD_REQUEST, "Error Message"
			error STATUS_ERROR, "Server Error Message"
 			meta :meta => {:status => STATUS_SUCCESS, :message => "Signup Completed"}, :driver => Driver.new().as_json(:auth => true)
			def signup_driver
				if params[:driver][:driver_type].blank?
					params[:driver][:driver_type] = "CAR"
				end
				params[:driver][:driver_type] = Driver.driver_types[params[:driver][:driver_type].upcase]
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
				param :name, String, :required => true
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

			api :POST, "api/v1/client/login", "Login Client"
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
			api :POST, "api/v1/logout", "Logout User (driver/client)"
			# param_group :device
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "User Logged Out"}
			def logout
				@driver = current_driver
				if @driver.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Driver not found"}}
				end
				
				@driver.update_attributes(:driver_availability => Driver.driver_avilabilities[:OFFLINE])
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Driver Logged Out"}}
			end

			api :PUT, "/api/v1/driver", "Update driver"
			param :avilability, Driver.driver_avilabilities.keys, :required => true
			header :Authorization, 'Token token=Access Token', :required => true
			error STATUS_ERROR, "Driver not found"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Driver updated"}
			def update_driver
				@driver = current_driver
				if @driver.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Driver not found"}}					
				end
				@driver.update_attributes(:driver_availability => Driver.driver_avilabilities["#{params[:avilability]}"])
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Driver Updated"}}
			end

			api :PUT, "/api/v1/client", "Update client location"
			param :lat, String
			param :long, String
			param :address, String
			header :Authorization, 'Token token=Access Token', :required => true
			error STATUS_ERROR, "Driver not found"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Client location updated"}
			def update_client_location
				@user = current_user
				if @user.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Client not found"}}					
				end
				@user.update_attributes(lat: params[:lat], long: params[:long], address: params[:address])
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Clinet location updated"}}
			end


			private 
				def user_params
					params[:client].permit(:email, :phone,:image_url,:password,:name)
				end

				def driver_params
					params[:driver].permit(:email, :phone,:image_url,:password,:name,:driver_type)
				end
		end
	end
end
