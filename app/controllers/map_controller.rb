class MapController < ApplicationController
    

	def map
		@drivers_table = Driver.order(id: :ASC).paginate(:page => params[:page],per_page: 10)
		@drivers = Driver.all.order(id: :ASC)
		render :map
	end

	def driver_available
		driver = Driver.where(:id => params[:id].to_i).first
		if driver.present?
			driver.driver_state = Driver.driver_states[:AVAILABLE]
			driver.save
			driver.firebase_migrate
		end
		redirect_to :map
	end
end
