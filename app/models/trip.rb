class Trip < ApplicationRecord
	enum trip_states: [:PENDING, :ACCEPTED, :NOT_SERVED, :EXPIRED, :IN_PROGRESS, :COMPLETED, :CANCELLED, :REJECTED]
	belongs_to :user
	has_many :trip_drivers
	#belongs_to :driver
=begin
	- Client —> 
	  1) PENDING
	  2) ACCEPTED
   	  3) NOT_SERVED
	- Driver —> 
	1) PENDING
  	2) EXPIRED
	3) IN_PROGRESS
	4) COMPLETED
	5) CANCELLED
	6) REJECTED
=end

	def trip_state_string
		# if driver
			case self.trip_state
			when 1
				'Pending'
			when 2
				'Expired'
			when 3
				'In Progress'
			when 4
				'Completed'
			when 5
				'Cancelled'
			when 6
				'Rejected'
			end
		# else
		# 	case self.trip_state
		# 	when 1
		# 		'Pending'
		# 	when 2
		# 		'Accepted'
		# 	when 3
		# 		'Not served'
		# 	end
		# end
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
