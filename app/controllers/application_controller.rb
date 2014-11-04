class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper

  def after_sign_in_path_for(resource)
    url_for contacts_path
  end

  def after_sign_out_path_for(resource)
    root_url
  end

  def user_params
    params[:user].permit(:email, :password, :job_type, :type, :skip_existing_checking,
                         :relationships_attributes => [:contact_id, :association_type, :role, :id, :"_destroy"],
                         :companies_attributes => [:id, :company_name, :phone_1, :phone_2,
                                                   :phone_tag_1, :phone_tag_2, :address_line_1,
                                                   :address_line_2, :city, :state, :zipcode, :website],
                         :people_attributes => [:id, :first_name, :last_name, :phone_1, :phone_2,
                                                :phone_tag_1, :phone_tag_2, :address_line_1,
                                                :address_line_2, :city, :state, :zipcode, :website])
  end

end
