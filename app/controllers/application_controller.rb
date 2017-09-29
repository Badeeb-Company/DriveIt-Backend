class ApplicationController < ActionController::Base
#  protect_from_forgery with: :exception
require "distance_calculator.rb"
before_action :authenticate_admin!, :except => [:test_google_api]
	def reset_trip
		Trip.all.each do |trip|
			trip.update_attributes(:trip_state => Trip.trip_states[:notServed])
		end
		Driver.all.each do |driver|
			driver.invited = false
			driver.save
		end
	end

	def test_google_api
		# drivers = [{:id => 1, "lat" => 20, "long" => 12}, {:id => 2, "lat" => 29.972207, "long" => 31.244723}]
		# client = {:id => 1, "lat" => 29.969375, "long" => 31.242907}
		# distance_calculator = DistanceCalculator.new()
		# return render :json => {:result => distance_calculator.calculate_distance(drivers,client)}

		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		index  = 0
		lat = [31.242250,31.2422,31.242255,31.2422, 31.242255]
		long = [29.968526,29.968526,29.968526,29.9685,29.9685]
		response = firebase.set("locations/drivers/5/",{:lat => lat[0], :long => long[0] })
		while index <= 1000
			index = index + 1
    		response = firebase.set("locations/drivers/1/",{:lat => lat[1], :long => long[1] })
    		long[1] = long[1] + 0.00002
    		response = firebase.set("locations/drivers/2/",{:lat => lat[2], :long => long[2] })
    		long[2] = long[2] - 0.00002
    		response = firebase.set("locations/drivers/3/",{:lat => lat[3], :long => long[3] })
    		lat[3] = lat[3] - 0.00002
    		response = firebase.set("locations/drivers/4/",{:lat => lat[4], :long => long[4] })
    		lat[4] = lat[4] + 0.00002

    	end
    	return render :json => "Success"
	end
end
