Setting.create(
	key: Setting::SEARCH_MAX_DISTANCE,
	value: '5',
	description: 'Maximum distance (in km) to search when finding drivers'
	)

Setting.create(
	key: Setting::DRIVER_TIMEOUT,
	value: '20',
	description: 'The time (in seconds) a request is available for a driver before expiry'
	)