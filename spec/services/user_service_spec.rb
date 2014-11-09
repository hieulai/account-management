require 'rails_helper'

RSpec.describe UserService do

  context "as a Person User" do
    let (:existing) { FactoryGirl.create :real_person_user }
    describe ".create" do
      context "happy flow" do
        subject { FactoryGirl.build :real_person_user }
        it "should be created" do
          expect(UserService.create subject).not_to be_new_record
        end
      end

      context "if user with same info exists" do
        before do
          @user = FactoryGirl.build :real_person_user
          @user.profile.first_name = existing.profile.first_name
          @user.profile.last_name = existing.profile.last_name
          @user = UserService.create(@user)
        end
        it "should not be created" do
          expect(@user).to be_new_record
        end
        it "should return existing errors" do
          expect(@user.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".update" do
      context "happy flow" do
        before do
          user_params = {email: "test@gmail.com", people_attributes: {id: existing.profile.id, first_name: "John"}}
          @user = UserService.update(existing, user_params)
        end
        it "should update email" do
          expect(@user.email).to eq("test@gmail.com")
        end
        it "should update first name" do
          expect(@user.profile.first_name).to eq("John")
        end
      end

      context "if user with same info exists" do
        before do
          @user = FactoryGirl.create :real_person_user
          user_params = {people_attributes: {id: @user.profile.id, first_name: existing.profile.first_name, last_name: existing.profile.last_name}}
          @user = UserService.update(@user, user_params)
        end
        it "should return existing errors" do
          expect(@user.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".search_for_existings" do
      before do
        @user = FactoryGirl.build :real_person_user
      end

      context "with same name" do
        before do
          @user.profile.first_name = existing.profile.first_name
          @user.profile.last_name = existing.profile.last_name
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

      context "with same phone" do
        before do
          @user.profile.phone_1 = existing.profile.phone_1
          @user.profile.phone_tag_1 = existing.profile.phone_tag_1
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

      context "with same website" do
        before do
          @user.profile.website = existing.profile.website
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

      context "with same email" do
        before do
          @user.email = existing.email
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

    end
  end

  context "as a Company User" do
    let (:existing) { FactoryGirl.create :real_company_user }
    describe ".create" do
      context "happy flow" do
        subject { FactoryGirl.build :real_company_user }
        it "should be created" do
          expect(UserService.create subject).not_to be_new_record
        end
      end

      context "if user with same info exists" do
        before do
          @user = FactoryGirl.build :real_company_user
          @user.profile.company_name = existing.profile.company_name
          @user = UserService.create(@user)
        end
        it "should not be created" do
          expect(@user).to be_new_record
        end
        it "should return existing errors" do
          expect(@user.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".update" do
      before do
        @user = FactoryGirl.create :real_company_user
      end

      context "happy flow" do
        before do
          user_params = {companies_attributes: {id: @user.profile.id, company_name: "ACME"}}
          @user = UserService.update(@user, user_params)
        end
        it "should update company name" do
          expect(@user.profile.company_name).to eq("ACME")
        end
      end

      context "if user with same info exists" do
        before do
          user_params = {companies_attributes: {id: @user.profile.id, company_name: existing.profile.company_name}}
          @user = UserService.update(@user, user_params)
        end
        it "should return existing errors" do
          expect(@user.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".search_for_existings" do
      before do
        @user = FactoryGirl.build :real_company_user
      end

      context "with same company name" do
        before do
          @user.profile.company_name = existing.profile.company_name
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

      context "with same phone" do
        before do
          @user.profile.phone_1 = existing.profile.phone_1
          @user.profile.phone_tag_1 = existing.profile.phone_tag_1
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end

      context "with same website" do
        before do
          @user.profile.website = existing.profile.website
        end
        it "should be found" do
          expect(UserService.search_for_existings @user).not_to be_empty
        end
      end
    end

  end

end
