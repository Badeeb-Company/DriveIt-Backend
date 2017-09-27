class DistanceCalculator
  require "google_maps_api.rb"
  def calculate_distance(drivers,client,trip)
    @drivers = drivers
    @client = client
    @trip = trip
    calculate_drivers_overhead_using_google_api() if !@drivers.empty?
    begin
      calculate_drivers_overhead_using_google_api() if !@drivers.empty?
    rescue Exception
      @api_failed = true
      Rails.logger.info('Google API limit reached while calculation of trip overhead', @trip)
    end
    return @drivers
  end

  def batch_drivers_sources
   return  @drivers.map {|driver| [driver["lat"],driver["long"]]}
  end

  def passenger_source
    return [@trip[:lat],@trip[:long]]
  end
  # Calculate Distance between Driver and location using google api
  def calculate_drivers_overhead_using_google_api()
    
    # Batching Google APIs
    p "Batch drivers Sources #{batch_drivers_sources}"
    p "passenger_source #{passenger_source}"
    p "API #{GoogleMapsApi::DRIVERS_OVERHEAD}"
    drivers_srcs_passenger_src = GoogleMapsApi.calculate_batch_cost_metric(
      batch_drivers_sources, [passenger_source],
      GoogleMapsApi::DRIVERS_OVERHEAD)
    @drivers.each_with_index do |driver,i|
      value = drivers_srcs_passenger_src[i]
      unless value.blank?
        driver[:distance] = {:distance => value[0], :time => value[1]}
      else
        @drivers -=[driver]
      end
    end
  end

  def exclude_drivers_with_long_time_to_pasenger(drivers_srcs_passenger_src)
    @drivers.each_with_index do |driver, i|
      time_to_passenger = drivers_srcs_passenger_src[i][1]
      if time_to_passenger.nil? || time_to_passenger > MAX_TIME_TO_PASSENGER
        @drivers -= [driver]
      end
    end
  end
end