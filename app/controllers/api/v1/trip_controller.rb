module Api
	module V1
		class TripController < BaseController
			require 'trip_handler.rb'

			STATUS_UNAUTHORIZED = "401"

			api :POST, "/api/v1/trip", "Request Trip (Client side)"
			param :destination, String, :required => true
			param :long, String, :required => true
			param :lat, String, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Requested"}, :trip => "Integer"
			def request_trip
				if current_user.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Not logged in"}}
				end
				# old_trip = Trip.where(:user_id => current_user.id, :trip_state => [Trip.trip_states[:pending], Trip.trip_states[:rejected]]).first
				# p "old_trip = #{old_trip}"	
				# # return render :status => STATUS_BAD_REQUEST, :json => {:meta => {:status => STATUS_BAD_REQUEST, :message => "Can't request more than one trip"}} unless old_trip.blank?
				@trip = Trip.new(:destination => params[:destination], :long => params[:long], :lat => params[:lat], :user_id => current_user.id, :trip_state => Trip.trip_states[:PENDING])
				return render :status => STATUS_ERROR, :json => {:meta => {:status => STATUS_ERROR, :message => @trip.errors.full_messages.first}} unless @trip.save
				handler = TripHandler.new(@trip)
				handler.find_driver()
				@trip = Trip.find(@trip.id)
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Trip Requested"}, :trip => @trip.id}
				#return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "/api/v1/trip/:trip_id/reject", "Reject Trip (Driver side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_UNPROCESSABEL, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Rejected"}			
			def reject_trip
				if current_driver.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Not logged in"}}
				end
				@trip = Trip.where(:id => params[:trip_id].to_i).first
				return render :status => STATUS_NotFound, :json => {:meta => {:status => STATUS_NotFound, :message => "Trip not found"}} if @trip.blank?
				if @trip.trip_state == Trip.trip_states[:PENDING] && @trip.driver_id == current_driver.id
					handler = TripHandler.new(@trip)
					handler.driver_rejected(current_driver,false)
					return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Trip Rejected"}}
				else
					return render :status => STATUS_UNPROCESSABEL, :json => {:meta => {:status => STATUS_UNPROCESSABEL, :message => "unprocessable_entity"}}
				end

			end

			api :POST, "/api/v1/trip/:trip_id/accept", "Accept Trip (Driver side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_UNPROCESSABEL, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Accepted"}, :trip => "Integer"
			def accept_trip
				if current_driver.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Not logged in"}}
				end
				@trip = Trip.where(:id => params[:trip_id].to_i).first
				return render :status => STATUS_NotFound, :json => {:meta => {:status => STATUS_NotFound, :message => "Trip not found"}} if @trip.blank?
				if @trip.trip_state == Trip.trip_states[:PENDING] && @trip.driver_id == current_driver.id
					handler = TripHandler.new(@trip)
					p "Current Driver #{current_driver}"
					handler.driver_accepted(current_driver)
					return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Trip Accepted"}, :trip => @trip.id}
				else
					return render :status => STATUS_UNPROCESSABEL, :json => {:meta => {:status => STATUS_UNPROCESSABEL, :message => "unprocessable_entity"}}
				end
			end

			api :POST, "/api/v1/trip/:trip_id/cancel", "Cancel Trip (Client side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Canceled"}, :trip => "Integer"
			def cancel_trip
				if current_user.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Not logged in"}}
				end
				@trip = Trip.where(:id => params[:trip_id].to_i).first
				return render :status => STATUS_NotFound, :json => {:meta => {:status => STATUS_NotFound, :message => "Trip not found"}} if @trip.blank?
				handler = TripHandler.new(@trip)
				handler.cancel_trip
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Trip Canceled"}, :trip => @trip.id}
			end
			api :POST, "/api/v1/trip/:trip_id/complete", "Complete Trip (Driver side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Completed"}, :trip => "Integer"			
			def complete_trip
				if current_driver.blank?
					return render :status => :unauthorized, :json => {:meta => {:status => STATUS_UNAUTHORIZED, :message => "Not logged in"}}
				end
				@trip = Trip.where(:id => params[:trip_id].to_i).first
				return render :status => STATUS_NotFound, :json => {:meta => {:status => STATUS_NotFound, :message => "Trip not found"}} if @trip.blank?
				handler = TripHandler.new(@trip)
				handler.complete_trip
				return render :status => STATUS_SUCCESS, :json => {:meta => {:status => STATUS_SUCCESS, :message => "Trip Completed"}, :trip => @trip.id}
			end
		end
	end
end
