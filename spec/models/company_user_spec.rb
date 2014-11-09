require 'rails_helper'

RSpec.describe CompanyUser, :type => :model do
  it_behaves_like "a paranoid"
  it_behaves_like "a user"

  describe "Associations" do
    it { expect(subject).to have_many :companies }
  end

  describe "Scopes" do
    context "has_company_name" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, company_name: "ACME")
      end
      it { expect(CompanyUser.has_company_name("ACME")).to include(@subject) }
    end

    context "has_phone" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, phone_1: "01")
      end
      it { expect(CompanyUser.has_phone("01")).to include(@subject) }
    end

    context "has_website" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, website: "http://google.com")
      end
      it { expect(CompanyUser.has_website("http://google.com")).to include(@subject) }
    end
  end
end
