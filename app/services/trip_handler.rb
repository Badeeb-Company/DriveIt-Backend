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
		@trip.trip_drivers.each do |driver|
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
			return {:driver_phone => "", :driver_id => 0,:distance_to_arrive => 0, :driver_address => "", :driver_image_url => "", :driver_name => "", :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 0, :state => Trip.trip_states.keys[@trip.trip_state]}
		end
		set_driver_dict(driver)
		p "Distance to arrive = #{@driver_dict[:distance][:distance]}"
		return {:driver_phone => driver.phone, :driver_id => driver.id,:distance_to_arrive => @driver_dict[:distance][:distance], :driver_address => "", :driver_image_url => driver.image_url, :driver_name => driver.name, :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => @driver_dict[:distance][:time], :state => Trip.trip_states.keys[@trip.trip_state]}
	end
	def driver_data(driver)
		set_driver_dict(driver)
		p "Distance to arrive = #{@driver_dict[:distance][:distance]}"
		return {:distance_to_arrive => @driver_dict[:distance][:distance],:client_address => @trip.destination, :client_id => @trip.user.id, :client_phone => @trip.user.phone, :client_image_url => @trip.user.image_url, :client_long => @trip.long, :client_lat => @trip.lat,:client_name => @trip.user.name, :client_phone => @trip.user.phone, :id => @trip.id, :state => Trip.trip_states.keys[@trip.trip_state]}
	end
	def set_driver_dict(driver)
		p "Drivers count = #{@fir_drivers.count}"
		@fir_drivers.each do |driver_dict|
			p "Checking driver dict #{driver_dict}"
			if driver_dict[:id].to_i == driver.id
				@driver_dict = driver_dict
				return
			end
		end
		@driver_dict = Hash.new()
		@driver_dict[:id] = 0
		@driver_dict[:distance] = Hash.new()
		@driver_dict[:distance][:distance] = 0
		@driver_dict[:distance][:time] = 0

			return {:driver_phone => "", :driver_id => 0,:distance_to_arrive => 0, :driver_address => "", :driver_image_url => "", :driver_name => "", :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 10, :state => Trip.trip_states.keys[@trip.trip_state]}
		end
		return {:driver_phone => driver.phone, :driver_id => driver.id,:distance_to_arrive => 0, :driver_address => "", :driver_image_url => driver.image_url, :driver_name => driver.name, :id => @trip.id, :state => @trip.trip_state, :time_to_arrive => 10, :state => Trip.trip_states.keys[@trip.trip_state]}
	end

	def find_driver
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.trip_state = Trip.trip_states[:pending]
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
			p "Driver Dict #{@driver_dict}"
			driver_id = @fir_drivers[@index][:id].to_i
			p "Driver ID = #{driver_id}"
			driver = Driver.where(id: driver_id, :invited => false).first
			p "Driver #{driver}"
			p "Invit Driver #{driver}"
			if driver.present?
				invite_driver(driver)
				delay(run_at: Rails.application.secrets.driver_timeout.seconds.from_now).invalidate_driver(driver)
				@trip.index = @index 
				@trip.save
				return
			end
			@index = @index + 1
		end
		p 'No Driver Avilable'
		not_served()
	end

	def invalidate_driver(driver)
		Rails.logger.info("Invalidate Driver")
		Rails.logger.info("Trip = #{@trip.as_json({})}")
		Rails.logger.info("Driver = #{driver.as_json({})}")
		@trip = Trip.find(@trip.id)
		if @trip.trip_state == Trip.trip_states[:pending] && @trip.driver_id.to_i == driver.id.to_i
			Rails.logger.info("Invalidate")
			driver_rejected(driver)
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
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.driver_id = driver.id
		@trip.trip_state = Trip.trip_states[:pending]
		driver.invited = true
		driver.save
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end

	def driver_accepted(driver)
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.driver_id = driver.id
		@trip.trip_state = Trip.trip_states[:beingServed]
		@trip.save
    	firebase.set("drivers/#{driver.id}/", {:state => "in_trip", :trip => self.driver_data(driver)})
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
	end

	def driver_rejected(driver)
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		# @trip.trip_state = Trip.trip_states[:notServed]
		# @trip.save
		driver.invited = false
		driver.save
		driver_data_rejected = self.driver_data(driver)
		driver_data_rejected[:state] = Trip.trip_states.keys[Trip.trip_states[:rejected]]
    	response = firebase.set("drivers/#{driver.id}/trip/", driver_data_rejected)
    	response = firebase.set("clients/#{@trip.user_id}/trip",self.client_data(driver))
    	unless response.success?
      		@trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
      	@index = @index + 1
      	choose_driver
	end

	def not_served
		firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
		@trip.update_attributes(:trip_state => Trip.trip_states[:notServed])
    	if @trip.driver_id.present?
    		driver = Driver.where(:id => @trip.driver_id).first
    		driver.invited = false
    		if driver.present?
		    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))

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
    		driver.invited = false
			driver.save
		end
		@trip.trip_state = Trip.trip_states[:completed]
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
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
    		driver.invited = false
			driver.save
		end

		@trip.trip_state = Trip.trip_states[:cancelled]
		@trip.save
    	response = firebase.set("drivers/#{driver.id}/trip/", self.driver_data(driver))
    	response = firebase.set("clients/#{@trip.user.id}/trip/",self.client_data(driver))
    	unless response.success?
      		trip.errors.add(:firebase, "Cannot save record")
      		return false
      	end
    end

end