class MapController < ApplicationController
    

	def map
		@drivers_table = Driver.where(driver_availability: 0)
			.order(id: :ASC)
			.paginate(:page => params[:page],per_page: 10)
			
		@drivers = Driver.where(driver_availability: 0)
		render :map
	end

end
