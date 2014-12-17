require 'rails_helper'

RSpec.describe "Contacts", type: :feature, js: true, :search => true do
  include Warden::Test::Helpers
  Warden.test_mode!

  before do
    user = UserService.create FactoryGirl.build :company_owner_person_user, email: "test@gmail.com", password: "123456"
    owner = user.employers.first
    login_as(user, :scope => :user, :run_callbacks => false)

    company_contact = UserService.create FactoryGirl.build :company_user
    company_contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
    @contact = ContactService.create(company_contact, user, owner)
    @person_user = UserService.create FactoryGirl.build :real_person_user
    @company_user = UserService.create FactoryGirl.build :real_company_user
    Sunspot.commit

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

    context "Employed by My Company" do
      before do
        choose "Employed by My Company"
      end

      scenario "Happy flow" do
        fill_in "First Name", :with => "A"
        fill_in "Last Name", :with => "Employee"
        click_button "Save"
        visit '/contacts/employees'
        expect(page).to have_text("A Employee")
      end
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

  context "Import Company Contacts" do
    scenario "Happy flow" do
      visit show_import_export_contacts_path

      file_path = File.expand_path("../../factories/Sample Companies.xlsx", __FILE__)
      attach_file('data', file_path)
      click_button "Import"

      expect(page).to have_text("All Contacts")
      expect(page).to have_text("Chaparros Foundation")
      expect(page).to have_text("1234 Make Belive")
      expect(page).to have_text("Austin")
      expect(page).to have_text("TX")
      expect(page).to have_text("78701")
      expect(page).to have_text("(512) 555-1234")
      expect(page).to have_text("Main")
      expect(page).to have_text("Huge Organization")
    end
  end

  context "Import Person Contacts" do
    scenario "Happy flow" do
      visit show_import_export_contacts_path

      file_path = File.expand_path("../../factories/Sample People.xlsx", __FILE__)
      attach_file('data', file_path)
      click_button "Import"

      expect(page).to have_text("All Contacts")
      expect(page).to have_text("Bill	Clinton")
      expect(page).to have_text("test4@test.com")
      expect(page).to have_text("(512) 555-3333")
      expect(page).to have_text("Office")
      expect(page).to have_text("Mr President")
    end

    scenario "Incorrect data" do
      visit show_import_export_contacts_path

      file_path = File.expand_path("../../factories/Wrong Person Contacts.xlsx", __FILE__)
      attach_file('data', file_path)
      click_button "Import"

      expect(page).to have_text("Import/Export Contacts")
      expect(page).to have_text("Importing Error at")
    end
  end
end
