class FirebaseController < ApplicationController

	api :GET, "drivers/:driver_id", "Path to use when driver listens for notifiaction"
	meta :trip_id => "Integer", :driver_state => User.user_states.keys, :long => "Float", :lat => "Float", :destination => String
	def driver_listener
		return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Firebase method"}
	end

	api :POST, "locations/drivers/:driver_id", "Path to use when driver updates his location"
	param :long, Float, :required => true
	param :lat, Float, :required => true
	def update_driver_location
		return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Firebase method"}
	end

	api :GET, "user/trip", "Path to use when user listens for notifiaction about current trip"
	meta :id => "Integer", :driver_id => "Integer", :trip_state => Trip.trip_states.keys
	
	def client_listener
		return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Firebase method"}
	end

end

=begin
# Notes
	Update Documentation (Check Firebase)
	Remove Update location/state
	Reject/Accept --> Remove Trip from response (only trip_id)
	Signup --> Add phone, remove long/lat, username, device
	Signin --> Remove device

	To be delivered
	1) Signup/login
	2) Flow without firebase & Google maps API
		- Request trip --> Pick First Driver, then next (no criteria 'Google maps')
		- First Driver to accept, Send to user
		- Support Cancel/Reject
	3) 
# 
=end