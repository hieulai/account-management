class RegistrationsController < Devise::RegistrationsController
  layout 'public'

  def create
    @user = CompanyUser.new(user_params)
    if @user.save
      sign_up(resource_name, resource)
      respond_with resource, :location => after_sign_up_path_for(resource)
    else
      render :new
    end
  end

  private
  def user_params
    params[:user].permit(:email, :password,
                         :companies_attributes => [:company_name, :phone_1, :phone_2,
                                                   :phone_tag_1, :phone_tag_2, :address_line_1,
                                                    :address_line_2, :city, :state, :zipcode,:website])
  end
end