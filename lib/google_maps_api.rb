require 'google_maps_service'

class GoogleMapsApi

  TRIP_ESTIMATES = 1
  DRIVERS_OVERHEAD = 2
  REMAINING_TIME = 3
  GEOCODE = 4

	DEFAULT_OPTIONS = {
    mode: 'driving',
		language: 'en-AU',
		# avoid: 'tolls',
		units: 'metric'
  }

  def self.calculate_route_cost_metric(origin, destination, api_type)
    route_cost_metric(origin, destination, api_type)
  end

  def self.calculate_route_cost_metric!(origin, destination, api_type)
    result = route_cost_metric(origin, destination, api_type)
    raise Exceptions::NoRoutesFound if result.nil?
    result
  end

  def self.calculate_batch_cost_metric(origins, destinations, api_type)
    p "Origins #{origins}"
    p "destionations #{destinations}"
    p "ApiType #{api_type}"
    matrix = get_distance_matrix(origins, destinations, api_type)
    parse_batch_matrix(matrix)
  end

	def self.get_route(driver_location, driver_destination, passenger_location, passenger_destination)
		client_directions.directions(driver_location, driver_destination, waypoints: [passenger_location, passenger_destination], mode: 'driving', alternatives: false)
	end

	def self.get_route_without_waypoints(location,destination)
		client_directions.directions(location, destination, mode:'driving', alternatives: false)
	end

  def self.coordinate_address(lat, lng)
    full_address = client_maps(GoogleMapsApi::GEOCODE).reverse_geocode([lat, lng])[0][:formatted_address]
    address_array = full_address.split(',')
    return address_array[0] + ',' + address_array[1] if address_array.size >= 2
    return ""
  end

  private

  def self.client_maps(api_type)
    case api_type
    when TRIP_ESTIMATES
      @@trip_estimates_maps ||= initialize_maps_api(Rails.application.secrets.google_maps_key_for_trip_estimates)
    when DRIVERS_OVERHEAD
      @@drivers_overhead_maps ||= initialize_maps_api(Rails.application.secrets.GoogleMaps_api_key)
    when REMAINING_TIME
      @@trip_remaining_time_maps ||= initialize_maps_api(Rails.application.secrets.google_maps_key_for_trip_remaining_time)
    when GEOCODE
      @@geocoding_maps ||= initialize_maps_api(Rails.application.secrets.google_geocoder_key)
    end
  end

  def self.initialize_maps_api(api_key)
    GoogleMapsService::Client.new(
      key: api_key,
      retry_timeout: 20,      # Timeout for retrying failed request
      queries_per_second: 10  # Limit total request per second
    )
  end

  def self.client_directions
    @@client_directions ||= GoogleMapsService::Client.new(
      key: Rails.application.secrets.google_directions_key,
      retry_timeout: 20,      # Timeout for retrying failed request
      queries_per_second: 10  # Limit total request per second
    )
  end

  def self.get_distance_matrix(origins, destinations, api_type, options=DEFAULT_OPTIONS)
    client_maps(api_type).distance_matrix(origins, destinations, options)
  end

  def self.route_cost_metric(origin, destination, api_type)
    matrix = get_distance_matrix(origin, destination, api_type)
    parse_route_matrix(matrix)
  end

  def self.parse_batch_matrix(matrix)
    data = []
    rows = matrix[:rows]
    rows.each do |row|
      elements = row[:elements]
      elements.each do |element|
        if element[:status] == 'OK'
          data << [element[:distance][:value], element[:duration][:value]]
        else
          data << nil
        end
      end
    end
    data
  end

  # parses one route matrix (with one origin and one destination)
  def self.parse_route_matrix(matrix)
    results = matrix[:rows]
    # passenger_origin to passenger_destination
    route = results[0][:elements][0]

    if route[:status] == 'OK'
      return [route[:distance][:value], route[:duration][:value]]
    end
    nil
  end

end
