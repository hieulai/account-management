class RegistrationsController < Devise::RegistrationsController
  layout 'public'

  def build_resource(hash=nil)
    super(hash)
    self.resource.type ||= PersonUser.name
    self.resource = self.resource.becomes(PersonUser)
    self.resource.job_type ||= Constants::SELF_EMPLOYED
    self.resource.people.build
    self.resource
  end

  def create
    if params[:user_id].present?
      existing_user = User.find(params[:user_id])
      self.resource = UserService.update(existing_user, user_params)
    else
      self.resource = PersonUser.new(user_params)
      self.resource = UserService.create self.resource
    end

    if self.resource.errors.empty?
      sign_up(resource_name, self.resource)
      respond_with resource, :location => after_sign_up_path_for(self.resource)
    else
      if @user.errors[:existing].any?
        @user.skip_existing_checking = true
        render :register_existing_user
      else
        render :new
      end
    end
  end

  def after_sign_up_path_for(resource)
    if resource.job_type == Constants::COMPANY_CONTACT && resource.employers.empty?
      url_for registrations_show_create_company_path
    else
      url_for contacts_path
    end
  end

  def show_create_company
    @user = CompanyUser.new
    @profile = @user.companies.build
    render :show_create_company
  end

  def create_company
    @user = User.new(user_params)
    respond_to do |format|
      @user = ContactService.create(@user, current_user, root_user)
      @profile = @user.profile
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully created.' }
        format.json { render 'contacts/show', status: :created, location: @user }
      else
        format.html do
          if @user.errors[:existing].any?
            @user.skip_existing_checking = true
            render :add_existing_company
          else
            render :show_create_company
          end
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end