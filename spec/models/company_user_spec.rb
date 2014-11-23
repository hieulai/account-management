# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean
#  type                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  deleted_at             :time
#

require 'rails_helper'

RSpec.describe CompanyUser, :type => :model do
  it_behaves_like "a paranoid"
  it_behaves_like "a user"

  describe "Associations" do
    it { expect(subject).to have_many :companies }
  end

  describe "Scopes" do
    describe "has_company_name" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, company_name: "ACME")
      end
      it { expect(CompanyUser.has_company_name("ACME")).to include(@subject) }
    end

    describe "has_phone" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, phone_1: "512.555.4321")
      end
      it { expect(CompanyUser.has_phone("512.555.4321")).to include(@subject) }
      it { expect(CompanyUser.has_phone("(512) 555-4321")).to include(@subject) }
    end

    describe "has_website" do
      before do
        @subject = FactoryGirl.create :company_user
        @subject.companies << FactoryGirl.build(:company, website: "http://google.com")
      end
      it { expect(CompanyUser.has_website("http://google.com")).to include(@subject) }
    end
  end
end
