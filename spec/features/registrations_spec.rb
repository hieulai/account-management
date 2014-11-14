require 'rails_helper'

RSpec.describe "Registrations", type: :feature do
  before do
    @existing = UserService.create FactoryGirl.build :real_person_user, email: "test@gmail.com", password: "123456"
    @contact = UserService.create FactoryGirl.build :contact_person_user
  end

  scenario "Register with an existed email" do
    visit '/users/sign_up'
    within("#new_user") do
      fill_in "user[email]", :with => "test@gmail.com"
      fill_in "user[password]", :with => "123456"

      fill_in "user[people_attributes][0][first_name]", :with => "Test"
      fill_in "user[people_attributes][0][last_name]", :with => "User"
    end

    click_button 'Create'
    expect(page).to have_text("This email is already registered")
  end

  scenario "Register with existed user info" do
    visit '/users/sign_up'
    within("#new_user") do
      fill_in "user[email]", :with => "somebody@gmail.com"
      fill_in "user[password]", :with => "123456"

      fill_in "user[people_attributes][0][first_name]", :with => @contact.profile.first_name
      fill_in "user[people_attributes][0][last_name]", :with => @contact.profile.last_name
    end

    click_button 'Create'
    expect(page).to have_text("Are any of these people you?")

  end

  context "Register as a self-employed person" do
    scenario "With new info" do

    end
  end

  context "Register as a company employed person" do

    scenario "With new info" do

    end
  end
end
