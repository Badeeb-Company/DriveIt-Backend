class MapController < ApplicationController

	def map
		@drivers = Driver.all
		render :map
	end
end
