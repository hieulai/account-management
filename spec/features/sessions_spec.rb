require 'rails_helper'

RSpec.describe "Sessions", type: :feature, :search => true do
  before do
    UserService.create FactoryGirl.build :real_person_user, email: "test@gmail.com", password: "123456"
    Sunspot.commit
  end

  scenario "User login with correct credentials" do
    visit "/users/sign_in"
    within("#new_user") do
      fill_in "user[email]", :with => "test@gmail.com"
      fill_in "user[password]", :with => "123456"
    end
    click_button "Login"

    expect(page).to have_text("Contacts")
  end

  scenario "User login with incorrect credentials" do
    visit "/users/sign_in"
    within("#new_user") do
      fill_in "user[email]", :with => "nobody@gmail.com"
      fill_in "user[password]", :with => "fake"
    end
    click_button "Login"

    expect(page).to have_text("Invalid email or password")
  end
end

