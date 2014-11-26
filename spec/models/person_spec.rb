# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  first_name     :string(255)
#  last_name      :string(255)
#  phone_1        :string(255)
#  phone_2        :string(255)
#  phone_tag_1    :string(255)
#  phone_tag_2    :string(255)
#  address_line_1 :string(255)
#  address_line_2 :string(255)
#  city           :string(255)
#  state          :string(255)
#  zipcode        :string(255)
#  website        :string(255)
#  user_id        :integer
#  deleted_at     :time
#

require 'rails_helper'

RSpec.describe Person, :type => :model do

  it_behaves_like "a paranoid"

  describe "Attributes" do
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:phone_1) }
    it { should respond_to(:phone_2) }
    it { should respond_to(:phone_tag_1) }
    it { should respond_to(:phone_tag_2) }
    it { should respond_to(:website) }
    it { should respond_to(:address_line_1) }
    it { should respond_to(:address_line_2) }
    it { should respond_to(:city) }
    it { should respond_to(:state) }
    it { should respond_to(:zipcode) }
    it { should respond_to(:website) }
    it { should respond_to(:status) }
    it { should respond_to(:display_name) }
  end

  describe "Validations" do
    it { expect(subject).to validate_uniqueness_of(:first_name).scoped_to(:last_name, :phone_1, :phone_2, :address_line_1, :address_line_2, :city, :state, :zipcode, :website).with_message(Constants::PERSON_UNIQUENESS) }
    it { expect(subject).to validate_presence_of(:first_name) }
    it { expect(subject).to validate_presence_of(:last_name) }
    it "fails validation with invalid phone number" do
      expect(FactoryGirl.build :invalid_phone_person).not_to be_valid
    end
  end

  describe "Associations" do
    it { expect(subject).to belong_to :user }
  end

  describe "Scopes" do

  end

  describe "Behaviors" do
    context "is a contact" do
      subject { FactoryGirl.build :contact_person, status: Constants::CONTACT }
      it "should not validate last_name" do
        expect(subject).not_to validate_presence_of(:last_name)
      end
    end
  end
end
