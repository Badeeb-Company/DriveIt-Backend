class MapController < ApplicationController
    WillPaginate.per_page = 2

	def map
		@drivers_table = Driver.order(id: :ASC).paginate(:page => params[:page])
		@drivers = Driver.all.order(id: :ASC)
		render :map
	end

	def driver_available
		driver = Driver.where(params[:id].to_i).first
		if driver.present?
			driver.driver_state = Driver.driver_states[:AVAILABLE]
			driver.save
			driver.firebase_migrate
		end
		redirect_to :map
	end
end
