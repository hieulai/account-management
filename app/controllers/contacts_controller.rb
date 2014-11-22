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


  def merge
    respond_to do |format|
      @updated_contact = User.find(params[:updated_contact])
      if params[:user][:id].present?
        @user = User.find(params[:user][:id])
        @user.attributes = user_params
      else
        @user = User.new(user_params)
      end

      @user = ContactService.merge(@user, @updated_contact, root_user)
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :add_existing_contact }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_import_export
  end

  def import
    if params[:data].nil?
      redirect_to show_import_export_contacts_path, notice: "No file to import."
    else
      result = ContactService.import(params[:data], root_user)
      if result[:errors].empty?
        redirect_to contacts_url
      else
        redirect_to show_import_export_contacts_path, notice: result[:errors].join(",")
      end
    end
  end

  def export
    respond_to do |format|
      if params[:type] == Constants::COMPANY
        @contacts = root_user.company_contacts
      else
        @contacts = root_user.person_contacts.ignores([current_user.id])
      end
      format.csv { send_data ContactService.export(@contacts, params[:type], root_user), :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename= #{params[:type]} Contacts.csv" }
      format.xls { send_data ContactService.export(@contacts, params[:type], root_user, col_sep: "\t"), :type => 'application/xls; charset=utf-8; header=present', :disposition => "attachment; filename= #{params[:type]} Contacts.xls" }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @user = User.find params[:id]
    @profile = @user.profile
  end

end
