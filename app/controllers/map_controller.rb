class MapController < ApplicationController

	def map
		@drivers = Driver.all.order(id: :ASC)
		render :map
	end
end
