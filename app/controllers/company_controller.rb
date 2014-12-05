class CompanyController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_role
  before_action :set_user

  def current
  end

  def edit
  end


  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to current_company_index_path, notice: 'User was successfully updated.' }
        format.json { render :current, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_user
    @user = root_user
  end
end
