class Trip < ApplicationRecord
	enum trip_states: [:pending, :notServed, :beingServed, :completed, :cancelled, :rejected]
	belongs_to :user
	#belongs_to :driver
	def driver
		return nil if self.driver_id.blank?
		return Driver.where(:id => self.driver_id).first
	end
	def as_json (options = {})
		json = super.as_json(options)
		json["trip_state"] = Trip.trip_states.keys[json["trip_state"].to_i]
		return json
	end

end
