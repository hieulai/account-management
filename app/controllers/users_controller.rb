class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :add_existing_contact, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_existing_contact
    respond_to do |format|
      @user.update(user_params)
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render 'contacts/add_existing_contact' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user].permit(:email, :password, :type,
                           :relationships_attributes => [:contact_id, :association_type, :id, :"_destroy"],
                           :companies_attributes => [:id, :company_name, :phone_1, :phone_2,
                                                     :phone_tag_1, :phone_tag_2, :address_line_1,
                                                     :address_line_2, :city, :state, :zipcode, :website])
    end
end
