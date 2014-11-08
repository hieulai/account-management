class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:current, :edit, :update, :destroy]

  def current
  end


  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to current_users_path, notice: 'User was successfully updated.' }
        format.json { render :current, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_existing_contact
    respond_to do |format|
      @user = UserService.update(root_user, user_params)
      if @user.errors.empty?
        format.html { redirect_to contacts_url, notice: 'User was successfully updated.' }
        format.json { render :current, status: :ok, location: @user }
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
end
