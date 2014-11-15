require 'rails_helper'

RSpec.describe "Contacts", type: :feature, js: true do
  include Warden::Test::Helpers
  Warden.test_mode!

  before do
    user = UserService.create FactoryGirl.build :real_person_user, email: "test@gmail.com", password: "123456"
    login_as(user, :scope => :user, :run_callbacks => false)

    company_contact = UserService.create FactoryGirl.build :company_user
    company_contact.relationships << FactoryGirl.build(:relationship, contact: user, association_type: Constants::CLIENT)
    @contact = ContactService.create company_contact, user
    @person_user = UserService.create FactoryGirl.build :real_person_user
    @company_user = UserService.create FactoryGirl.build :real_company_user

    visit '/contacts'
    expect(page).to have_text("Contacts")
  end

  context "Add new Person Contact" do
    before do
      click_link "New Person"
      expect(page).to have_text("Add Person User")
    end

    context "Type Self-Employed" do
      before do
        choose "Self-Employed"
        check "association_type_Vendor"
      end

      scenario "Happy flow" do
        fill_in "First Name", :with => "A"
        fill_in "Last Name", :with => "Person"
        click_button "Save"
        expect(page).to have_text("A Person")
      end

      scenario "Add existing Person User" do
        fill_in "First Name", :with => @person_user.profile.first_name
        fill_in "Last Name", :with => @person_user.profile.last_name
        click_button "Save"
        expect(page).to have_text("Link Person User")

        click_link 'Yes'
        expect(page).to have_text(@person_user.display_name)
      end
    end

    context "Type Employed by Company" do
      before do
        choose "Employed by Company"
      end

      scenario "Happy flow" do
        fill_in "First Name", :with => "A"
        fill_in "Last Name", :with => "Employee"
        click_button "Save"
        expect(page).to have_text("A Employee")
      end

      # TODO:
      # scenario "Add existing Person User" do
      #
      # end
    end

  end

  context "Add new Company Contact" do
    before do
      click_link "New Company"
      expect(page).to have_text("Add Company User")
    end

    scenario "Happy flow" do
      check "association_type_Vendor"
      fill_in "Company Name", :with => "ACME"
      click_button "Save"
      expect(page).to have_text("ACME")
    end

    scenario "Add existing Company User" do
      check "association_type_Vendor"
      fill_in "Company Name", :with => @company_user.profile.company_name
      click_button "Save"
      expect(page).to have_text("Link Company User")

      click_link 'Yes'
      expect(page).to have_text(@company_user.profile.company_name)
    end
  end

  context "Add new Company Employee Contact" do
    scenario "Happy flow" do
      find('tr', text: @contact.display_name).click
      expect(page).to have_text("Company Information")

      click_link "Add Company Contact"
      expect(page).to have_text("Add Person User")

      fill_in "First Name", :with => "A"
      fill_in "Last Name", :with => "Company Employee"
      click_button 'Save'
      expect(page).to have_text("A Company Employee")
    end

  end
end
