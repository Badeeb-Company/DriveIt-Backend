class MapController < ApplicationController
    WillPaginate.per_page = 2

	def map
		@drivers_table = Driver.order(id: :ASC).paginate(:page => params[:page])
		@drivers = Driver.all.order(id: :ASC)
		render :map
	end
end
