class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :show_assign_to_company, :assign_to_company]

  # GET /users
  # GET /users.json
  def index
    @contacts = root_user.contacts.ignores([current_user.id])
  end

  def vendors
    @contacts = root_user.vendors
  end

  def clients
    @contacts = root_user.clients
  end

  def employees
    @contacts = root_user.employees.ignores([current_user.id])
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new(type: params[:type])
    @profile = @user.send(:"#{@user.type_name.underscore.pluralize}").build
    if params[:association_type] && params[:contact_id]
       @user.relationships.build(association_type: params[:association_type], contact_id: params[:contact_id])
    end
  end

  # GET /users/1/edit
  def edit
    @user.skip_existing_checking = !@user.is_real?
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      @user = ContactService.create(@user, root_user)
      @profile = @user.profile
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html do
          if @user.errors[:existing].any?
            @user.skip_existing_checking = true
            render :add_existing_contact
          else
            render :new
          end
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      @user = ContactService.update(@user, user_params, root_user)
      @profile = @user.profile
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          if @user.errors[:existing].any?
            @user.skip_existing_checking = true
            render :add_existing_contact
          else
            render :edit
          end
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = ContactService.destroy(@user, root_user)
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def show_assign_to_company
  end

  def assign_to_company
    respond_to do |format|
      @user = ContactService.update(@user, user_params, root_user)
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @user = User.find params[:id]
    @profile = @user.profile
  end

end
