# == Schema Information
#
# Table name: relationships
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_id       :integer
#  association_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  reflex           :boolean
#  role             :string(255)
#  deleted_at       :time
#

require 'rails_helper'

RSpec.describe Relationship, :type => :model do
  it_behaves_like "a paranoid"

  describe "Attributes" do
    it { should respond_to(:association_type) }
    it { should respond_to(:reflex) }
    it { should respond_to(:role) }
  end

  describe "Validations" do
    it { expect(subject).to validate_presence_of(:contact) }
    it { expect(subject).to validate_inclusion_of(:association_type).in_array(Constants::ASSOCIATION_TYPES) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :user }
    it { expect(subject).to belong_to :contact }
  end

  describe "Scopes" do
    let(:user) { FactoryGirl.create :user }
    context "contact_by" do
      subject { FactoryGirl.create :relationship, contact_id: user.id }
      it { expect(Relationship.contact_by(user)).to include(subject) }
    end

    context "vendors" do
      subject { FactoryGirl.create :relationship, association_type: Constants::VENDOR }
      it { expect(Relationship.vendors).to include(subject) }
    end

    context "clients" do
      subject { FactoryGirl.create :relationship, association_type: Constants::CLIENT }
      it { expect(Relationship.clients).to include(subject) }
    end

    context "employees" do
      subject { FactoryGirl.create :relationship, association_type: Constants::EMPLOYEE }
      it { expect(Relationship.employees).to include(subject) }
    end
    context "employers" do
      subject { FactoryGirl.create :relationship, association_type: Constants::EMPLOYER }
      it { expect(Relationship.employers).to include(subject) }
    end

    context "type_having" do
      subject { FactoryGirl.create :relationship, association_type: Constants::HAS }
      it { expect(Relationship.type_having).to include(subject) }
    end
    context "type_belong" do
      subject { FactoryGirl.create :relationship, association_type: Constants::BELONG }
      it { expect(Relationship.type_belong).to include(subject) }
    end

    context "owners" do
      subject { FactoryGirl.create :relationship, association_type: Constants::EMPLOYER, role: Constants::OWNER }
      it { expect(Relationship.owners).to include(subject) }
    end
  end

  describe "Behaviors" do
    subject { FactoryGirl.create :relationship }
    context "after_create" do
      it "should create a reflection" do
        expect(subject.reflection).not_to be_nil
      end
    end

    context "after_destroy" do
      before do
        @reflection = subject.reflection
        subject.destroy
      end
      it "should destroy its reflection" do
        expect(Relationship.exists?(@reflection.id)).to be_falsey
      end
    end
  end
end
