class ContactsController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :relationships]

  # GET /users
  # GET /users.json
  def index
    @users = current_user.contacts
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new(type: params[:type])
    @user.relationships.build(:association_type => Constants::UNDEFINED)
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        create_default_relationships
        format.html { redirect_to contacts_url, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        create_default_relationships
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user.contacts.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params[:user].permit(:email, :password, :type,
                         :relationships_attributes => [:contact_id, :association_type, :id, :"_destroy"],
                         :companies_attributes => [:company_name, :phone_1, :phone_2,
                                                   :phone_tag_1, :phone_tag_2, :address_line_1,
                                                   :address_line_2, :city, :state, :zipcode, :website],
                         :people_attributes => [:first_name, :last_name, :phone_1, :phone_2,
                                                :phone_tag_1, :phone_tag_2, :address_line_1,
                                                :address_line_2, :city, :state, :zipcode, :website])
  end

  def create_default_relationships
    @user.relationships.create(:association_type => Constants::UNDEFINED, :contact_id => current_user.id) if @user.relationships.empty?
  end
end
