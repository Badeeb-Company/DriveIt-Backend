class DistanceCalculator
  require "google_maps_api.rb"
  def calculate_distance(drivers,client)
    @drivers = drivers
    @client = client
    calculate_drivers_overhead_using_google_api()
  end

  def batch_drivers_sources
    @drivers.map {|driver| [driver["lat"],driver["long"]]}
  end

  def passenger_source
    return [@client["lat"],@client["long"]]
  end
  # Calculate Distance between Driver and location using google api
  def calculate_drivers_overhead_using_google_api()
    
    # Batching Google APIs
    drivers_srcs_passenger_src = GoogleMapsApi.calculate_batch_cost_metric(
      batch_drivers_sources, [passenger_source],
      GoogleMapsApi::DRIVERS_OVERHEAD)
    return drivers_srcs_passenger_src
    # # Exclude drivers with time to passenger greater than 10 minutes
    # exclude_drivers_with_long_time_to_pasenger(drivers_srcs_passenger_src)

    # # Cache drivers sources to passenger for further uses
    # cache_drivers_srcs_passenger_src(drivers_srcs_passenger_src)

    # passenger_dest_drivers_dests = GoogleMapsApi.calculate_batch_cost_metric(
    #   [passenger_destination], batch_drivers_destinations,
    #   GoogleMapsApi::DRIVERS_OVERHEAD)


    # # Run concurrently not in parallel which helps because of
    # # redis and google api calls
    # Parallel.each_with_index(@drivers, in_threads: 4) do |driver, i|
    #   driver_to_passenger_cost = drivers_srcs_passenger_src[i]
    #   passenger_destination_to_driver_desination_cost = passenger_dest_drivers_dests[i]
    #   driver_route_cost = GoogleMapsApi.calculate_route_cost_metric(driver.location.to_a, driver.destination.to_a, GoogleMapsApi::DRIVERS_OVERHEAD)

    #   next if driver_to_passenger_cost.nil? ||
    #       passenger_destination_to_driver_desination_cost.nil? ||
    #       driver_route_cost.nil?

    #   # Calculating extra time and extra distance
    #   extra_distance = driver_to_passenger_cost[0] +
    #     passenger_route_cost[0] +
    #     passenger_destination_to_driver_desination_cost[0] -
    #     driver_route_cost[0]

    #   extra_time = driver_to_passenger_cost[1] +
    #     passenger_route_cost[1] +
    #     passenger_destination_to_driver_desination_cost[1] -
    #     driver_route_cost[1]

    #   # Cache the result in Redis
    #   cache_drivers_overhead(driver, extra_distance, extra_time)
    # end
    # Rails.logger.info('Done trip overhead calculation using Google API', @trip)
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