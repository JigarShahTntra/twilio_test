class UsersController < ApplicationController
  include Verify
  before_action :set_user, only: [:show, :edit, :update, :destroy, :resend]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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
      # create authy user
      create_authy_user(user_params['country_code'], user_params['phone_number'], user_params['email'])
      # Send Verification Code
      send_token
      redirect_to @user, notice: 'You have a valid phone number!'
    else
      redirect_to @user, alert: 'invalid or expired token'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:code].present?
      token = Authy::API.verify(id: @user.authy_id, token: params[:code])
      if token.ok?
        @user.update(verified: true)
        redirect_to users_path, notice: "#{@user.phone_number} has been verified!"
      else
        redirect_to @user, alert: 'invalid or expired token'
      end
    elsif @user.update(user_params)
      redirect_to root_path
    else
      redirect_to @user, alert: 'invalid update entries.'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def resend
    unless @user.authy_id.present?
      create_authy_user(@user.country_code, @user.phone_number, @user.email)
    end
    send_token
    redirect_to @user
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id] || params[:user_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :country_code, :phone_number, :email)
    end
end
