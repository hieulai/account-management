require 'rails_helper'

RSpec.describe "Registrations", type: :feature, :search => true do
  before do
    @existing = UserService.create FactoryGirl.build :real_person_user, email: "test@gmail.com", password: "123456"
    @contact = FactoryGirl.create :contact_person_user
    @company_contact = FactoryGirl.create :company_user
    Sunspot.commit
  end

  scenario "Register with an existing email" do
    visit '/users/sign_up'
    within("#new_user") do
      fill_in "Email", :with => "test@gmail.com"
      fill_in "Password", :with => "123456"

      fill_in "First Name", :with => "Test"
      fill_in "Last Name", :with => "User"
    end

    click_button 'Create'
    expect(page).to have_text("This email is already registered")
  end

  context "Register with existing user info", js: true do
    before do
      visit '/users/sign_up'
      within("#new_user") do
        fill_in "Email", :with => "somebody@gmail.com"
        fill_in "Password", :with => "123456"

        fill_in "First Name", :with => @contact.profile.first_name
        fill_in "Last Name", :with => @contact.profile.last_name
        fill_in "Primary Phone", :with => FactoryGirl.generate(:phone)
      end

      click_button 'Create'
      expect(page).to have_text("Are any of these people you?")
    end
    scenario "Link Person User" do
      click_link 'Yes'
      expect(page).to have_text("Contacts")
    end

    scenario "Create new Person User" do
      click_link 'No'
      expect(page).to have_text("Contacts")
    end
  end

  context "Register as a self-employed person" do
    scenario "Happy flow" do
      visit '/users/sign_up'
      within("#new_user") do
        fill_in "Email", :with => "somebody@gmail.com"
        fill_in "Password", :with => "123456"

        fill_in "First Name", :with => "Some"
        fill_in "Last Name", :with => "Body"
      end

      click_button 'Create'
      expect(page).to have_text("Contacts")
    end
  end

  context "Register as a company employed person", js: true do
    before do
      visit '/users/sign_up'
      within("#new_user") do
        fill_in "Email", :with => "somebody@gmail.com"
        fill_in "Password", :with => "123456"
        choose "Work for Company"

        fill_in "First Name", :with => "Some"
        fill_in "Last Name", :with => "Body"
        click_button 'Create'
      end
    end

    scenario "Happly flow" do
      expect(page).to have_text("What company do you work for?")

      fill_in "Company Name", :with => "ACME"
      click_button 'Save'
      expect(page).to have_text("Contacts")
    end

    context "Register with existing company info" do
      before do
        expect(page).to have_text("What company do you work for?")
        fill_in "Company Name", :with => @company_contact.profile.company_name
        fill_in "Primary Phone", :with => FactoryGirl.generate(:phone)

        click_button 'Save'
        expect(page).to have_text("Link Company User")
      end

      scenario "Link Company User" do
        click_link 'Yes'
        expect(page).to have_text("Contacts")
      end

      scenario "Create new Company User" do
        click_link 'No'
        expect(page).to have_text("Contacts")
      end
    end
  end
end
