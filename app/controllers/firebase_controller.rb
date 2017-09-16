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

	api :GET, "user/:trip_id", "Path to use when user listens for notifiaction about current trip"
	meta :trip_id => "Integer", :driver_id => "Integer", :trip_state => ["Pending", "Inprogress", "Rejected", "Completed"]
	
	def client_listener
		return render :status => STATUS_ERROR, :meta => {:status => STATUS_ERROR, :message => "Firebase method"}
	end

end
