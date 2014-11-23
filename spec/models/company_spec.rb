# == Schema Information
#
# Table name: companies
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  company_name   :string(255)
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

RSpec.describe Company, :type => :model do
  it_behaves_like "a paranoid"

  describe "Attributes" do
    it { should respond_to(:company_name) }
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
    it { expect(subject).to validate_uniqueness_of(:company_name).scoped_to(:phone_1, :phone_2, :website) }
    it { expect(subject).to validate_presence_of(:company_name) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :user }
  end

  describe "Scopes" do
  end

  describe "Behaviors" do
  end
end
