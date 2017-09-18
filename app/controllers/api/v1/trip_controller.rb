module Api
	module V1
		class TripController < BaseController
			skip_before_action :authenticate_user!, :except => [:request_trip, :cancel_trip]
			skip_before_action :authenticate_driver!, :except => [:reject_trip, :accept_trip]

			api :POST, "/api/v1/trip", "Request Trip (Client side)"
			param :destination, String, :required => true
			param :long, Float, :required => true
			param :lat, Float, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Requested"}, :trip => Trip.new().as_json()
			def request_trip
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "/api/v1/trip/reject", "Reject Trip (Driver side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Rejected"}, :trip_id => "Integer"			
			def reject_trip
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "/api/v1/trip/accept", "Accept Trip (Driver side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Accepted"}, :trip_id => "Integer"
			def accept_trip
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			api :POST, "/api/v1/trip/cancel", "Cancel Trip (Client side)"
			param :trip_id, :number, :required => true
			header :Authorization, 'Access Token', :required => true
			error STATUS_ERROR, "Server Error Message"
			error STATUS_NotFound, "Trip Not Found"
			error STATUS_BAD_REQUEST, "Error Message"
			meta :meta => {:status => STATUS_SUCCESS, :message => "Trip Canceled"}, :trip_id => "Integer"
			def cancel_trip
				return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			end

			# api :PATCH, "/api/v1/user/location", "Update User location"
			# param :long, Float, :required => true
			# param :lat, Float, :required => true
			# header :Authorization, 'Access Token', :required => true
			# error STATUS_ERROR, "Server Error Message"
			# error STATUS_BAD_REQUEST, "Error Message"
			# meta :meta => {:status => STATUS_SUCCESS, :message => "Location updated"}
			# def update_location
			# 	return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			# end

			# api :PATCH, "/api/v1/user/state", "Update User location (Driver side), if driver is not available/in_trip for a while, he will be converted to offline"
			# param :user_state, User.user_states.keys, :required => true
			# header :Authorization, 'Access Token', :required => true
			# error STATUS_ERROR, "Server Error Message"
			# error STATUS_BAD_REQUEST, "Error Message"
			# meta :meta => {:status => STATUS_SUCCESS, :message => "Location updated"}
			# def driver_state
			# 	return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Method not implemented"}
			# end

		end
	end
end
