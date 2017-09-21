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
		drivers = [{:id => 1, :lat => 20, :long => 10}, {:id => 2, :lat => 20, :long => 12}]
		client = {:id => 1, :lat => 20, :long => 11}
		distance_calculator = DistanceCalculator.new()
		return render :json => {:result => distance_calculator.calculate_distance(drivers,client)}
	end
end
