module Api
	module V1
		class BaseController < ApplicationController
		#	before_action :authenticate_user!
		#	before_action :authenticate_driver!
			# around_filter :set_current_user
 			rescue_from Apipie::ParamError do |e|
      			render :status => STATUS_ERROR, :json => {:meta => {:status => STATUS_ERROR, :message => e.message}} 
   			end
   			def set_current_driver
   				if current_driver.blank?
   					Current.driver = nil
   				else
   					Current.driver = current_driver
   				end
   			end
  			def set_current_user
    			if current_user.blank?
      				Current.user = nil
    			else
      				Current.user = current_user
    			end
  			end         

			def authenticate_user!
				p "authenticate_user !!!"
			    # p current_admin
			    authenticate_or_request_with_http_token do |token, options|
				    # user = User.where(access_token: token).first
				    # return user #&& session[user.id]
				    p User.exists?(token: token)
				    User.exists?(token: token)
			    end
			end

			
			def authenticat_driver!
				p "authenticat_driver"
				authenticate_or_request_with_http_token do |token, options|
					p Driver.exists?(token: token)
					User.exists?(token: token)
				end
			end

			def current_user
			    authenticate_or_request_with_http_token do |token, options|
			    	user =  User.where(token: token).first
			    	return user
			    end
			end
			def current_driver
				authenticate_or_request_with_http_token do |token,options|
					driver = Driver.where(:token => token).first
					return driver
				end
			end

			private
			def authenticate_my_user
			    p "authenticate my user !!!"
			    authenticate_or_request_with_http_token do |token, options|
			      	p User.exists?(token: token) || !authenticate_admin!.nil?
			      	User.exists?(token: token) || !authenticate_admin!.nil?
			    end
			end
			def authenticate_my_driver
			    p "authenticate my driver !!!"
			    authenticate_or_request_with_http_token do |token, options|
			      	p Driver.exists?(token: token)# || !authenticate_admin!.nil?
			      	Driver.exists?(token: token)# || !authenticate_admin!.nil?
			    end
			end
			
		end
	end
end
