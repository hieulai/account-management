require 'rails_helper'

RSpec.describe ContactService do
  let (:owner) { FactoryGirl.create :real_company_user }
  context "as a Person User Contact" do
    let (:contact) { FactoryGirl.build :real_person_user }
    describe ".create" do
      context "happy flow" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should be created" do
          expect(@contact).not_to be_new_record
        end

        it "should create default association" do
          expect(@contact.belong_relationships).not_to be_empty
        end
      end

      context "if has no relationships with owner" do
        context "as a normal contact" do
          it "should not be created" do
            expect(ContactService.create contact, owner).to be_new_record
          end
        end

        context "as a company contact" do
          before do
            @contact = FactoryGirl.create :company_contact_person_user
          end
          it "should be created" do
            expect(ContactService.create @contact, owner).not_to be_new_record
          end
        end
      end

      context "if same email with existing contact" do
        before do
          existing = FactoryGirl.create :real_person_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact.email = existing.email
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end
      end

      context "if duplication" do
        before do
          existing = FactoryGirl.create :real_person_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact.profile.first_name = existing.profile.first_name
          contact.profile.last_name = existing.profile.last_name
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_person_user
          contact.profile.first_name = existing.profile.first_name
          contact.profile.last_name = existing.profile.last_name
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end

        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end

    end

    describe ".update" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, owner
      end

      context "happy flow" do
        before do
          contact_params = {email: "test@gmail.com"}
          @contact = ContactService.update @contact, contact_params, owner
        end

        it "should be saved" do
          expect(@contact.email).to eq("test@gmail.com")
        end
      end

      context "if has no relationships with owner" do
        context "as a normal contact" do
          before do
            @contact.reload
            contact_params = {relationships_attributes: []}
            @contact.relationships.contact_by(owner).each do |r|
              contact_params[:relationships_attributes] << {id: r.id, :"_destroy" => true}
            end
            @contact = ContactService.update @contact, contact_params, owner
          end
          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

        context "as a company contact" do
          before do
            @contact = FactoryGirl.create :company_contact_person_user
            contact_params = {relationships_attributes: []}
            @contact.relationships.contact_by(owner).each do |r|
              contact_params[:relationships_attributes] << {id: r.id, :"_destroy" => true}
            end
            @contact = ContactService.update @contact, contact_params, owner
          end

          it "should be created" do
            expect(@contact.errors).to be_empty
          end
        end

      end

      context "if same email with existing contact" do
        before do
          existing = FactoryGirl.create :real_person_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact_params = {email: existing.email}
          @contact = ContactService.update contact, contact_params, owner
        end
        it "should not be created" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if duplication" do
        before do
          existing = FactoryGirl.create :real_person_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact_params = {people_attributes: [{id: contact.profile.id, first_name: existing.profile.first_name, last_name: existing.profile.last_name}]}
          @contact = ContactService.update contact, contact_params, owner
        end
        it "should not be created" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_person_user
          contact_params = {people_attributes: [{id: contact.profile.id, first_name: existing.profile.first_name, last_name: existing.profile.last_name}]}
          @contact = ContactService.update contact, contact_params, owner
        end
        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end

    end

    describe ".destroy" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, owner
      end

      context "as a contact" do
        before do
          contact_user = FactoryGirl.create :company_user
          @contact = ContactService.destroy contact_user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
        end

        it "should destroy user" do
          expect(PersonUser.exists?(@contact.id)).to be_falsey
        end
      end

      context "as a real user" do
        before do
          ContactService.destroy contact, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(contact)).to be_empty
          expect(contact.relationships.contact_by(owner)).to be_empty
        end

        it "should not destroy user" do
          expect(PersonUser.exists?(contact.id)).to be_truthy
        end
      end
    end
  end

  context "as a Company User Contact" do
    let (:contact) { FactoryGirl.build :real_company_user }
    describe ".create" do
      context "happy flow" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should be created" do
          expect(@contact).not_to be_new_record
        end
        it "should create default assoication" do
          expect(@contact.belong_relationships).not_to be_empty
        end
      end

      context "if has no relationships with owner" do
        it "should not be created" do
          expect(ContactService.create contact, owner).to be_new_record
        end
      end

      context "if duplication" do
        before do
          existing = FactoryGirl.create :real_company_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact.profile.company_name = existing.profile.company_name
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_company_user
          contact.profile.company_name = existing.profile.company_name
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end

        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".update" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, owner
      end

      context "happy flow" do
        before do
          contact_params = {companies_attributes: [{id: contact.profile.id, company_name: "ACME"}]}
          @contact = ContactService.update @contact, contact_params, owner
        end

        it "should be saved" do
          expect(@contact.profile.company_name).to eq("ACME")
        end
      end

      context "if has no relationships with owner" do
        before do
          contact_params = {relationships_attributes: []}
          contact.relationships.each do |r|
            contact_params[:relationships_attributes] << {id: r.id, :"_destroy" => true}
          end
          @contact = ContactService.update @contact, contact_params, owner
        end
        it "should not be saved" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if duplication" do
        before do
          existing = FactoryGirl.create :real_company_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact_params = {companies_attributes: [{id: contact.profile.id, company_name: existing.profile.company_name}]}
          @contact = ContactService.update contact, contact_params, owner
        end
        it "should not be created" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_company_user
          contact_params = {companies_attributes: [{id: contact.profile.id, company_name: existing.profile.company_name}]}
          @contact = ContactService.update contact, contact_params, owner
        end
        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".destroy" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, owner
      end

      context "as a contact" do
        before do
          contact_user = FactoryGirl.create :company_user
          @contact = ContactService.destroy contact_user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
        end

        it "should destroy user" do
          expect(CompanyUser.exists?(@contact.id)).to be_falsey
        end
      end

      context "as a real user" do
        before do
          ContactService.destroy contact, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(contact)).to be_empty
          expect(contact.relationships.contact_by(owner)).to be_empty
        end

        it "should not destroy user" do
          expect(CompanyUser.exists?(contact.id)).to be_truthy
        end
      end
    end
  end
end
