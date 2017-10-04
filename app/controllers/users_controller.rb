class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(:page => params[:page], :per_page => 10).order(:id)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def activate
    @user.update(activated: true)
    redirect_to users_url, notice: 'User was successfully activated.'
  end

  # deactivate user + set offline + reset token
  def deactivate
    @user.update(
      activated: false, 
      token: User.new_token
      )
    redirect_to users_url, notice: 'User was successfully deactivated.'
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {}).permit(:email, :name, :phone)
    end
end
