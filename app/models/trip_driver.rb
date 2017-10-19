class TripDriver < ApplicationRecord
	belongs_to :driver
	belongs_to :trip

	def class_name(i)
		trip_index = self.trip.index
		trip_state = self.trip.trip_state
		if i < trip_index
			'previously-invited'
		elsif i > trip_index
			''
		elsif i == trip_index && trip_state == 0
			return 'being-invited'
		elsif i == trip_index && (trip_state == 1 || trip_state == 4 || trip_state == 5)
			'accepted'
		else
			'previously-invited'
		end
	end
end
