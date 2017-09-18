class ApplicationController < ActionController::Base
#  protect_from_forgery with: :exception
	def reset_trip
		Trip.all.each do |trip|
			trip.update_attributes(:trip_state => Trip.trip_states[:notServed])
		end
		Driver.all.each do |driver|
			driver.invited = false
			driver.save
		end
	end
end
