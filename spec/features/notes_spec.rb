require 'rails_helper'

RSpec.describe "Notes", type: :feature, js: true do
  include Warden::Test::Helpers
  Warden.test_mode!

  before do
    @user = UserService.create FactoryGirl.build :real_person_user, email: "test@gmail.com", password: "123456"
    company_contact = UserService.create FactoryGirl.build :company_user
    company_contact.relationships << FactoryGirl.build(:relationship, contact: @user, association_type: Constants::CLIENT)
    company_contact.notes << FactoryGirl.build(:note, owner: @user, content: "This is test note")
    @contact = ContactService.create company_contact, @user
  end

  context "Notes belongs to user" do
    before do
      login_as(@user, :scope => :user, :run_callbacks => false)
    end

    scenario "Should see content in contacts screen" do
      visit '/contacts'

      expect(page).to have_text(@contact.display_name)
      expect(page).to have_text("This is test note")
    end

    scenario "Should see content in show screen" do
      visit "/contacts/#{@contact.id}"

      expect(page).to have_text("Information")
      expect(page).to have_text("This is test note")
    end
  end

  context "Notes don't belong to user" do
    before do
      @user2 = UserService.create FactoryGirl.build :real_person_user, email: "test2@gmail.com", password: "123456"
      contact_params = {relationships_attributes: [{association_type: Constants::CLIENT, contact_id: @user2.id}]}
      ContactService.update(@contact, contact_params, @user2)
      login_as(@user2, :scope => :user, :run_callbacks => false)
    end

    scenario "Should not see content in show screen" do
      visit "/contacts"

      expect(page).to have_text(@contact.display_name)
      expect(page).not_to have_text("This is test note")
    end


    scenario "Should not see content in show screen" do
      visit "/contacts/#{@contact.id}"

      expect(page).to have_text("Information")
      expect(page).not_to have_text("This is test note")
    end
  end

end
