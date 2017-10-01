class TripHandler
	attr_accessor :trip

	def initialize (trip)
		@trip = trip
		@trip_location = [trip.lat,trip.long].to_a
		@index = trip.index
		@fir_drivers = []
		load_drivers
	end
	def load_drivers
		@trip.trip_drivers.order(id: :ASC).each do |driver|
			driver_dict = Hash.new()
			driver_dict[:id] = driver.driver_id
			driver_dict[:distance] = Hash.new
			driver_dict[:distance][:distance] = driver.distance
			driver_dict[:distance][:time] = driver.time
			@fir_drivers.append(driver_dict)
		end
	end
	def cache_drivers
		@fir_drivers.each do |driver|
			p "Saving Driver #{driver}"
			dr = TripDriver.new(:driver_id => driver[:id].to_i, :trip_id => @trip.id, :distance => driver[:distance][:distance].to_f, :time => driver[:distance][:time].to_f)
			dr.save
		end
	end
	def client_data(driver)
		if driver.blank?
			return {:driver_phone => "", :driver_id => 0,:distance_to_arrive => 0, :driver_address => "", :driver_image_url => "", :driver_name => "", :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 0, :state => Trip.trip_states.keys[@trip.trip_state], :driver_type => ""}
		end
		set_driver_dict(driver)
		p "Distance to arrive = #{@driver_dict[:distance][:distance]}"
		return {:driver_phone => driver.phone, :driver_id => driver.id,:distance_to_arrive => @driver_dict[:distance][:distance], :driver_address => "", :driver_image_url => driver.image_url, :driver_name => driver.name, :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => @driver_dict[:distance][:time], :state => Trip.trip_states.keys[@trip.trip_state], :driver_type => driver.get_driver_type}
	end
	def driver_data(driver)
		set_driver_dict(driver)
		p "Distance to arrive = #{@driver_dict[:distance][:time]}"
		return {:distance_to_arrive => @driver_dict[:distance][:distance],:client_address => @trip.destination, :client_id => @trip.user.id, :client_phone => @trip.user.phone, :client_image_url => @trip.user.image_url, :client_long => @trip.long, :client_lat => @trip.lat,:client_name => @trip.user.name, :client_phone => @trip.user.phone, :id => @trip.id, :state => Trip.trip_states.keys[@trip.trip_state],:time_to_arrive => @driver_dict[:distance][:time], :driver_type => driver.get_driver_type}
	end
	def set_driver_dict(driver)
		
		@fir_drivers.each do |driver_dict|
			if driver_dict[:id].to_i == driver.id.to_i
				@driver_dict = driver_dict
				return
			end
		end
		@driver_dict = Hash.new()
		@driver_dict[:id] = 0
		@driver_dict[:distance] = Hash.new()
		@driver_dict[:distance][:distance] = 0
		@driver_dict[:distance][:time] = 0
	end


	def find_driver
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.trip_state = Trip.trip_states[:PENDING]
    	@trip.save
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(nil))	
		delay.request_drivers
		# request_drivers
	end
	def request_drivers
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		response = firebase.get("locations/drivers/", nil)
		p "Request Drivers Repsone #{response}"
		unless response.success?
			self.not_served
			return
		end
		p response
		@fir_drivers = response.body
		p "FIR Drivers #{@fir_drivers}"
		@fir_drivers = filter_drivers(@fir_drivers)
		p "Filtered Drivers #{@fir_drivers}"
		cache_drivers
		choose_driver
	end
	def choose_driver
		Rails.logger.info("Drivers Count = #{@fir_drivers.count}")
		Rails.logger.info("Current Index = #{@index}")
		while not @index >= @fir_drivers.count

			@driver_dict = @fir_drivers[@index]
			Rails.logger.info("Driver Dict #{@driver_dict}")
			driver_id = @fir_drivers[@index][:id].to_i
			Rails.logger.info("Driver ID = #{driver_id}")
			driver = Driver.where(id: driver_id, :driver_state => Driver.driver_states[:AVAILABLE], :driver_availability => Driver.driver_avilabilities[:ONLINE]).first
			Rails.logger.info("Will check Driver #{driver.id}")
			if driver.present?
				Rails.logger.info("Will invite Driver #{driver.id}")
				invite_driver(driver)
				delay(run_at: Rails.application.secrets.driver_timeout.seconds.from_now).invalidate_driver(driver)
				@trip.index = @index 
				@trip.save
				return
			end
			Rails.logger.info("Driver with id =#{driver.id} can't be invited")
			@index = @index + 1
			@trip.index = @index 
			@trip.save
		end
		@trip.index = @index 
		@trip.save
		p 'No Driver Avilable'
		not_served()
	end

	def invalidate_driver(driver)
		Rails.logger.info("Invalidate Driver")
		Rails.logger.info("Trip = #{@trip.as_json({})}")
		Rails.logger.info("Driver = #{driver.as_json({})}")
		@trip = Trip.find(@trip.id)
		if @trip.trip_state == Trip.trip_states[:PENDING] && @trip.driver_id.to_i == driver.id.to_i
			Rails.logger.info("Invalidate")
			driver_rejected(driver,true)
		else
			Rails.logger.info("Keep Request")
		end
	end

	def filter_drivers(drivers)
		filtered_drivers = []
		p "Filter drivers #{drivers}"
		# p "Driver keys = #{drivers.keys}"
		drivers.keys.each do |driver_id|
			# p "Checking driver with id = #{driver_id}, location = #{drivers["#{driver_id}"]}"
			driver_location = drivers["#{driver_id}"].to_a
			driver = Driver.where(:id => driver_id, :driver_availability => Driver.driver_avilabilities[:ONLINE], :driver_state => [Driver.driver_states[:AVAILABLE], Driver.driver_states[:INVITED]]).first
			if driver.present?
				# p driver_location
				driver_source = [driver_location[0].last,driver_location[1].last].to_a
				# p driver_source
				# p @trip_location
				driver_to_passenger_cost = Geocoder::Calculations::distance_between(driver_source, @trip_location, units: :km)
				if driver_to_passenger_cost <= (Rails.application.secrets.max_distance)
					dict = Hash.new()
					dict[:id] = driver_id
					dict[:distance] = Hash.new()
					dict[:distance][:distance] = (driver_to_passenger_cost*1000.0).to_i
					dict[:distance][:time] = 0
					dict["lat"] = driver_source[0]
					dict["long"] = driver_source[1]
					filtered_drivers.append(dict)
				end
			end
		end
		# Then sort them
		p "Display Drivers"
		p "Filtered Drivers. = #{filtered_drivers}"
		sorted_drivers = filtered_drivers.sort_by { |k| k[:distance][:distance].to_i }
		distance_calculator = DistanceCalculator.new()
		p "Sorted Drivers without Google is #{sorted_drivers}"
		sorted_drivers = distance_calculator.calculate_distance(sorted_drivers,@trip.user,@trip)
		p "Sorted Drivers with Google is #{sorted_drivers}"
		return sorted_drivers
	end

		# return drivers_fir
		# @drivers = 
		# driver = Driver.first
		# self.invite_driver(driver)
		# end
	def invite_driver(driver)
		@trip = Trip.find(@trip.id)
		if @trip.trip_state == Trip.trip_states[:PENDING]
			firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
			@trip.driver_id = driver.id
			# @trip.trip_state = Trip.trip_states[:PENDING]
			driver.driver_state = Driver.driver_states[:INVITED]
			driver.save
			@trip.save
			response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
			response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
			unless response.success?
				@trip.errors.add(:firebase, "Cannot save record")
				return false
			end
		else
			return false
		end
	end

	def driver_accepted(driver)
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.driver_id = driver.id
		@trip.trip_state = Trip.trip_states[:IN_PROGRESS]
		@trip.save
		driver.update_attributes(:driver_state => Driver.driver_states[:IN_TRIP])
    	firebase.set("drivers/#{driver.id}/", {:state => "in_trip", :trip => self.driver_data(driver)})
    	client_data_dict =  self.client_data(driver)
    	client_data_dict[:state] = Trip.trip_states.keys[Trip.trip_states[:ACCEPTED]]
    	response = firebase.set("clients/#{@trip.user.id}/trip/",client_data_dict)
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end

	def driver_rejected(driver,expired)
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		# @trip.trip_state = Trip.trip_states[:notServed]
		# @trip.save
		driver.update_attributes(:driver_state => Driver.driver_states[:AVAILABLE])

		driver_data_rejected = self.driver_data(driver)
		if expired
			driver_data_rejected[:state] = Trip.trip_states.keys[Trip.trip_states[:EXPIRED]]
    	else
			driver_data_rejected[:state] = Trip.trip_states.keys[Trip.trip_states[:REJECTED]]
    	end	
    	response = firebase.set("drivers/#{driver.id}/trip/", driver_data_rejected)
    	# response = firebase.set("clients/#{@trip.user_id}/trip",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
      	@index = @trip.index + 1
      	@trip.index = @index
      	@trip.save
      	choose_driver
	end

	def not_served
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.update_attributes(:trip_state => Trip.trip_states[:NOT_SERVED])
    	if @trip.driver_id.present?
    		driver = Driver.where(:id => @trip.driver_id).first
    		driver.update_attributes(:driver_state => Driver.driver_states[:AVAILABLE])
    		if driver.present?
		    	# response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
		    end
		end
		response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end
	def complete_trip
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		driver = @trip.driver
		unless driver.blank?
			p "Driver = #{driver}"			
    		driver.update_attributes(:driver_state => Driver.driver_states[:AVAILABLE])
			driver.save
		end
		@trip.trip_state = Trip.trip_states[:COMPLETED]
		@trip.save
		if driver.present?
    		response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
    	end
    	# response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end

	end
	def cancel_trip
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)

		driver = @trip.driver
		unless driver.blank?
			p "Driver = #{driver}"			
    		driver.update_attributes(:driver_state => Driver.driver_states[:AVAILABLE])
			driver.save
		end

		@trip.trip_state = Trip.trip_states[:CANCELLED]
		@trip.save
		if driver.present?
    		response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
    	end
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
    end

end