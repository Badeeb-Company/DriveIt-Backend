class MapController < ApplicationController
    

	def map
		@drivers_table = Driver.order(id: :ASC).paginate(:page => params[:page],per_page: 10)
		@drivers = Driver.all.order(id: :ASC)
		render :map
	end

end
