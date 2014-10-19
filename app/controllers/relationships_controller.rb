class RelationshipsController < ApplicationController
  before_action :set_contact
  before_action :set_relationship, only: [:show, :edit, :update, :destroy]

  # GET /relationships
  def index
    @relationships = @user.relationships.all
  end

  # GET /relationships/1
  def show
  end

  # GET /relationships/new
  def new
    @relationship = @user.relationships.new
  end

  # GET /relationships/1/edit
  def edit
  end

  # POST /relationships
  def create
    @relationship = @user.relationships.new(relationship_params)

    if @relationship.save
      redirect_to contact_relationships_path(@user), notice: 'Relationship was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /relationships/1
  def update
    if @relationship.update(relationship_params)
      redirect_to contact_relationships_path(@user), notice: 'Relationship was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /relationships/1
  def destroy
    @relationship.destroy
    redirect_to contact_relationships_path(@user), notice: 'Relationship was successfully destroyed.'
  end

  private
  def set_contact
    @user = User.find(params[:contact_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_relationship
    @relationship = @user.relationships.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def relationship_params
    params[:relationship].permit!
  end
end
