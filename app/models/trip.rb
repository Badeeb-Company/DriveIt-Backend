class Trip < ApplicationRecord
	enum trip_states: [:PENDING, :ACCEPTED, :NOT_SERVED, :EXPIRED, :IN_PROGRESS, :COMPLETED, :CANCELLED, :REJECTED]
	belongs_to :user
	has_many :trip_drivers
	#belongs_to :driver

	def trip_state_string
		case self.trip_state
		when 0
			'Pending'
		when 1
			'Accepted'
		when 2
			'Not served'
		when 3
			'Expired'
		when 4
			'In progress'
		when 5
			'Completed'
		when 6
			'Cancelled'
		when 7
			'Rejected'
		end
	end

	def driver_name
		return nil if self.driver_id.blank?
		return Driver.where(:id => self.driver_id).first.name
	end

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
