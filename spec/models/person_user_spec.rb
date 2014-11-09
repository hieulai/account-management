require 'rails_helper'

RSpec.describe PersonUser, :type => :model do
  it_behaves_like "a paranoid"
  it_behaves_like "a user"

  describe "Attributes" do
    it { should respond_to(:job_type) }
  end

  describe "Associations" do
    it { expect(subject).to have_many :people }
  end

  describe "Validations" do
    it { expect(subject).to validate_uniqueness_of(:email) }
    it { expect(subject).to validate_presence_of(:email) }
  end

  describe "Behaviors" do
    context "is a contact" do
      subject { FactoryGirl.build :person_user, status: Constants::CONTACT }
      it "should not validate email" do
        expect(subject).not_to validate_presence_of(:email)
      end
    end
  end
end
