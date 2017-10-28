class Setting < ApplicationRecord

	validates :key, :value, presence: true
	validates :key, uniqueness: true

	SEARCH_MAX_DISTANCE = 'SEARCH_MAX_DISTANCE'
	DRIVER_TIMEOUT = 'DRIVER_TIMEOUT'

	def self.get_value(key, default)
		result = Setting.find_by_key(key)
		if(result)
			result.value
		else
			default
		end
	end

end
