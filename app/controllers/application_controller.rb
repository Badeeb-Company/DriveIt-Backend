class ApplicationController < ActionController::Base
#  protect_from_forgery with: :exception
require "distance_calculator.rb"
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
		lat = 31.29
		long = 29.955
		while index <= 10000

    		response = firebase.set("locations/drivers/1/",{:lat => lat, :long => long })
    		index = index + 1
    		long = long + 0.01
    	end
    	return render :json => "Success"
	end
end
