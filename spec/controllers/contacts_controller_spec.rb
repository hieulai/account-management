require 'rails_helper'

RSpec.describe ContactsController, :type => :controller, :search => true do
  include_context "shared loggedin"

  let (:contact) { FactoryGirl.build :contact_person_user }
  let (:existing) { FactoryGirl.create :contact_person_user }

  describe "GET #index" do
    before do
      contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::CLIENT)
      @contact = ContactService.create contact, controller.current_user , controller.root_user
      Sunspot.commit
    end
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns @contacts' do
      get :index
      expect(assigns(:grouped_relationships)).not_to be_empty
    end
  end

  describe 'GET #vendors' do
    before do
      contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::VENDOR)
      @contact = ContactService.create contact, controller.current_user, controller.root_user
      Sunspot.commit
    end
    it 'renders the index template' do
      get :vendors
      expect(response).to render_template(:vendors)
    end


    it 'assigns @contacts' do
      get :vendors
      expect(assigns(:grouped_relationships)).not_to be_empty
    end
  end

  describe 'GET #clients' do
    before do
      contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::CLIENT)
      @contact = ContactService.create contact, controller.current_user, controller.root_user
      Sunspot.commit
    end
    it 'renders the index template' do
      get :clients
      expect(response).to render_template(:clients)
    end


    it 'assigns @contacts' do
      get :clients
      expect(assigns(:grouped_relationships)).not_to be_empty
    end

  end

  describe 'GET #employees' do
    before do
      contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
      @contact = ContactService.create contact, controller.current_user, controller.root_user
      Sunspot.commit
    end
    it 'renders the index template' do
      get :employees
      expect(response).to render_template(:employees)
    end

    it 'assigns @contacts' do
      get :employees
      expect(assigns(:grouped_relationships)).not_to be_empty
    end
  end


  describe 'GET #new' do
    it 'renders the new template' do
      get :new, type: "PersonUser"
      expect(response).to render_template(:new)
    end

    it 'initiates with type' do
      get :new, type: "PersonUser"
      expect(assigns(:user)).to be_a_new(PersonUser)
    end

    context "as a Company Contact" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, controller.current_user, controller.root_user
      end

      it 'initiates with EMPLOYEE relationships' do
        get :new, type: "PersonUser", association_type: Constants::EMPLOYEE, contact_id: @contact.id, role: Constants::STAFF_ROLES.sample
        expect(assigns(:user).relationships).not_to be_empty
      end
    end
  end

  describe 'POST #create' do
    let(:params) { {user: {type: "PersonUser",
                           relationships_attributes: [{association_type: Constants::CLIENT, contact_id: controller.root_user.id}],
                           people_attributes: [{first_name: "Test"}]}} }
    let(:invalid_params) { {user: {type: "PersonUser", people_attributes: [{first_name: "Test"}]}} }
    context "with valid params" do
      it 'saves the contact' do
        post :create, params
        expect(assigns(:user)).to be_a(PersonUser)
        expect(assigns(:user)).to be_persisted
      end

      it "redirect to index url" do
        post :create, params
        expect(response).to redirect_to(contacts_url)
      end

    end

    context "with invalid params" do
      it 'not save the contact' do
        post :create, invalid_params
        expect(assigns(:user)).not_to be_persisted
      end

      it "render new template" do
        post :create, invalid_params
        expect(response).to render_template(:new)
      end
    end

    context "with existing user data" do
      let(:existing_params) { {user: {type: "PersonUser",
                                      relationships_attributes: [{association_type: Constants::CLIENT, contact_id: controller.root_user.id}],
                                      people_attributes: [{first_name: existing.profile.first_name, last_name: existing.profile.last_name}]}} }


      it 'not save the contact' do
        post :create, existing_params
        expect(assigns(:user)).not_to be_persisted
      end

      it "render add_existing_contact template" do
        post :create, existing_params
        expect(response).to render_template(:add_existing_contact)
      end

      context "with skip_existing_checking" do
        it "save the contact" do
          existing_params[:user].merge!(skip_existing_checking: true)
          post :create, existing_params
          expect(assigns(:user)).to be_persisted
        end
      end
    end
  end

  context "contact exists" do
    before do
      contact.relationships << FactoryGirl.build(:relationship, contact: controller.root_user, association_type: Constants::CLIENT)
      @contact = ContactService.create contact, controller.current_user, controller.root_user
    end

    describe 'GET #show' do
      it 'renders the show template' do
        get :show, id: @contact.id
        expect(response).to render_template(:show)
      end

      it 'assigns @contacts' do
        get :show, id: @contact.id
        expect(assigns(:user)).to eq(@contact)
      end
    end

    describe 'GET #edit' do
      it 'renders the edit template' do
        get :edit, id: @contact.id
        expect(response).to render_template(:edit)
      end

      it 'assigns @user' do
        get :edit, id: @contact.id
        expect(assigns(:user)).to eq(@contact)
      end
    end

    describe 'PATCH #update' do
      let(:params) { {id: @contact.id, user: {people_attributes: [{id: @contact.profile.id, first_name: "Test"}]}} }
      let(:invalid_params) { {id: @contact.id, user: {people_attributes: [{id: @contact.profile.id, first_name: ""}]}} }
      context "with valid params" do
        it 'saves the contact' do
          patch :update, params
          expect(assigns(:user).profile.first_name).to eq("Test")
        end

        it "redirect to index url" do
          patch :update, params
          expect(response).to redirect_to(contacts_url)
        end
      end

      context "with invalid params" do
        it 'not save the contact' do
          patch :update, invalid_params
          expect(assigns(:user).errors).not_to be_empty
        end

        it "renders new template" do
          patch :update, invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the contact' do
        expect { delete :destroy, id: @contact.id }.to change(controller.root_user.contacts, :count).by(-1)
      end

      it "redirects to index url" do
        delete :destroy, id: @contact.id
        expect(response).to redirect_to(contacts_url)
      end
    end

    describe 'GET #show_assign_to_company' do
      it 'renders the edit template' do
        get :show_assign_to_company, id: @contact.id
        expect(response).to render_template(:show_assign_to_company)
      end

      it 'assigns @user' do
        get :show_assign_to_company, id: @contact.id
        expect(assigns(:user)).to eq(@contact)
      end
    end

    describe 'PUT #assign_to_company' do
      let(:params) { {id: @contact.id, user: {relationships_attributes: [{id: @contact.relationships.first.id, :"_destroy" => true},
                                                                         {association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample, contact_id: existing.id}]}} }

      it 'save the contact' do
        patch :assign_to_company, params
        expect(assigns(:user).employers).to include(existing)
      end

      it "redirect to index url" do
        patch :assign_to_company, params
        expect(response).to redirect_to(contacts_url)
      end
    end
  end

  describe 'POST #import' do

  end

  describe 'GET #export' do

  end

end
