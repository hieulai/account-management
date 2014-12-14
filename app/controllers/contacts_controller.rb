class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :delete, :destroy, :show_assign_to_company, :assign_to_company]

  # GET /users
  # GET /users.json
  def index
    @query = params[:query]
    @grouped_relationships = ContactService.search(@query, {page: params[:page], sort_field: params[:sort_field], sort_dir: params[:sort_dir]},
                                                   current_user, root_user)
  end

  def vendors
    @query = params[:query]
    @grouped_relationships = ContactService.search(@query, {page: params[:page], association_type: Constants::VENDOR, sort_field: params[:sort_field], sort_dir: params[:sort_dir]},
                                                   current_user, root_user)
  end

  def clients
    @query = params[:query]
    @grouped_relationships = ContactService.search(@query, {page: params[:page], association_type: Constants::CLIENT, sort_field: params[:sort_field], sort_dir: params[:sort_dir]},
                                                   current_user, root_user)
  end

  def employees
    @query = params[:query]
    @grouped_relationships = ContactService.search(@query, {page: params[:page], association_type: Constants::EMPLOYEE, sort_field: params[:sort_field], sort_dir: params[:sort_dir]},
                                                   current_user, root_user)
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
      @user.relationships.build(association_type: params[:association_type], contact_id: params[:contact_id], role: params[:role])
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
      @user = ContactService.create(@user, current_user, root_user)
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
      @user = ContactService.update(@user, user_params, current_user, root_user)
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

  def delete
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = ContactService.destroy(@user, current_user, root_user)
    respond_to do |format|
      format.html do
        if @user.errors.any?
          render :delete
        else
          redirect_to contacts_url, notice: 'User was successfully destroyed.'
        end
      end
      format.json { head :no_content }
    end
  end

  def show_assign_to_company
  end

  def assign_to_company
    respond_to do |format|
      @user = ContactService.update(@user, user_params, current_user, root_user)
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

      @user = ContactService.merge(@user, @updated_contact, current_user, root_user)
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
      result = ContactService.import(params[:data], current_user, root_user)
      if result[:errors].empty?
        redirect_to contacts_url
      else
        redirect_to show_import_export_contacts_path, notice: result[:errors].join(",")
      end
    end
  end

  def export
    respond_to do |format|
      @type = params[:type]
      if params[:type] == Constants::COMPANY
        @contacts = root_user.company_contacts
      else
        @contacts = root_user.person_contacts.ignores([current_user.id])
      end
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"#{@type} Contacts.xlsx\"" }
    end
  end

  private
  def set_contact
    @user = User.find params[:id]
    @profile = @user.profile
  end

end
