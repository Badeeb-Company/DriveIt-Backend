class DriversController < ApplicationController
  before_action :set_driver, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :available]

  # GET /drivers
  # GET /drivers.json
  def index
    @drivers = Driver.paginate(:page => params[:page], :per_page => 10).order(:id)
  end

  # GET /drivers/1
  # GET /drivers/1.json
  def show
  end

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  # GET /drivers/1/edit
  def edit
  end

  # POST /drivers
  # POST /drivers.json
  def create
    @driver = Driver.new(driver_params)

    if @driver.save
      redirect_to @driver, notice: 'Driver was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /drivers/1
  # PATCH/PUT /drivers/1.json
  def update
    if @driver.update(driver_params)
      redirect_to @driver, notice: 'Driver was successfully updated.'
    else
      render :edit
    end
  end

  def activate
    @driver.update(activated: true)
    redirect_to drivers_url, notice: 'Driver was successfully activated.'
  end

  # deactivate user + set offline + reset token
  def deactivate
    @driver.update(
      activated: false, 
      driver_availability: Driver.driver_avilabilities[:OFFLINE], 
      token: Driver.new_token
      )
    redirect_to drivers_url, notice: 'Driver was successfully deactivated.'
  end

  def available
    @driver.driver_state = Driver.driver_states[:AVAILABLE]
    @driver.save
    @driver.firebase_migrate

    redirect_to drivers_url, notice: 'Driver was successfully set available.'
  end

  # DELETE /drivers/1
  # DELETE /drivers/1.json
  def destroy
    @driver.destroy
    redirect_to drivers_url, notice: 'Driver was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_driver
      @driver = Driver.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def driver_params
      params.fetch(:driver, {}).permit(:email, :name, :phone)
    end
end
