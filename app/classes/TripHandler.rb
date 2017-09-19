class TripHandler
	attr_accessor :trip

	def initialize (trip)
		@trip = trip
		@trip_location = [trip.lat,trip.long].to_a
		@index = 0
		@fir_drivers = []
	end

	def client_data(driver)
		if driver.blank?
			return {:distance_to_arrive => 0, :driver_address => "", :driver_image_url => "", :driver_name => "", :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 10, :state => Trip.trip_states.keys[@trip.trip_state]}
		end
		return {:distance_to_arrive => 0, :driver_address => "", :driver_image_url => driver.image_url, :driver_name => driver.name, :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 10, :state => Trip.trip_states.keys[@trip.trip_state]}
	end
	def driver_data
		return {:client_address => @trip.destination, :client_image_url => @trip.user.image_url, :client_long => @trip.long, :client_lat => @trip.lat,:client_name => @trip.user.name, :client_phone => @trip.user.phone, :id => @trip.id, :state => Trip.trip_states.keys[@trip.trip_state]}
	end
	def find_driver
		firebase = Firebase::Client.new(FIR_Base_URL)
		response = firebase.get("locations/drivers/", nil)
		unless response.success?
			self.not_served
			return
		end
		@fir_drivers = response.body
		p "FIR Drivers #{@fir_drivers}"
		@fir_drivers = filter_drivers(@fir_drivers)
		p "Filtered Drivers #{@fir_drivers}"
		choose_driver()
	end
	def choose_driver
		while not @index >= @fir_drivers.count
			p "Checking First Driver" 	
			driver_id = @fir_drivers[@index]["driver_id"].to_i
			p "Invite Driver with id #{driver_id}"
			driver = Driver.where(id: driver_id, :invited => false).first
			p "Invit Driver #{driver}"
			if driver.present?
				invite_driver(driver)
				return
			end
			@index = @index + 1
		end
		p 'No Driver Avilable'
		not_served()
	end
	def filter_drivers(drivers)
		filtered_drivers = []
		# p "Driver keys = #{drivers.keys}"
		drivers.keys.each do |driver_id|
			# p "Checking driver with id = #{driver_id}, location = #{drivers["#{driver_id}"]}"
			driver_location = drivers["#{driver_id}"].to_a
			# p driver_location
			driver_source = [driver_location[0].last,driver_location[1].last].to_a
			# p driver_source
			# p @trip_location
			driver_to_passenger_cost = Geocoder::Calculations::distance_between(driver_source, @trip_location, units: :km)
			if driver_to_passenger_cost <= MAX_DISTANCE
				dict = Hash.new()
				dict["driver_id"] = driver_id
				dict["distance"] = driver_to_passenger_cost
				dict["lat"] = driver_source[0]
				dict["long"] = driver_source[1]
				filtered_drivers.append(dict)
			end
		end
		# Then sort them
		sorted_drivers = filtered_drivers.sort_by { |k| k["distance"] }
		return sorted_drivers
	end

		# return drivers_fir
		# @drivers = 
		# driver = Driver.first
		# self.invite_driver(driver)
		# end
	def invite_driver(driver)
		firebase = Firebase::Client.new(FIR_Base_URL)
		@trip.driver_id = driver.id
		@trip.trip_state = Trip.trip_states[:pending]
		driver.invited = true
		driver.save
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data)
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end

	def driver_accepted(driver)
		firebase = Firebase::Client.new(FIR_Base_URL)
		@trip.driver_id = driver.id
		@trip.trip_state = Trip.trip_states[:beingServed]
		@trip.save
    	firebase.set("drivers/#{driver.id}/", {:state => "in_trip", :trip => self.driver_data})
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end

	def driver_rejected(driver)
		firebase = Firebase::Client.new(FIR_Base_URL)
		# @trip.trip_state = Trip.trip_states[:notServed]
		# @trip.save
		driver.invited = false
		driver.save
		driver_data = self.driver_data
		driver_data[:state] = Trip.trip_states[:rejected]
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data)
    	response = firebase.set("clients/#{@trip.user_id}/trip",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
      	self.not_served
	end

	def not_served
		firebase = Firebase::Client.new(FIR_Base_URL)
		@trip.update_attributes(:trip_state => Trip.trip_states[:notServed])
    	if @trip.driver_id.present?
    		driver = Driver.where(:id => @trip.driver_id).first
    		driver.invited = false
    		if driver.present?
		    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data)

		    end
		end
		response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end
	def complete_trip
		firebase = Firebase::Client.new(FIR_Base_URL)
		driver = @trip.driver
		unless driver.blank?
			p "Driver = #{driver}"			
    		driver.invited = false
			driver.save
		end
		@trip.trip_state = Trip.trip_states[:completed]
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data)
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end

	end
	def cancel_trip
		firebase = Firebase::Client.new(FIR_Base_URL)

		driver = @trip.driver
		unless driver.blank?
			p "Driver = #{driver}"			
    		driver.invited = false
			driver.save
		end

		@trip.trip_state = Trip.trip_states[:cancelled]
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data)
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
    end

end