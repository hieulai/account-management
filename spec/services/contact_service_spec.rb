require 'rails_helper'

RSpec.describe ContactService do
  let (:user) {FactoryGirl.create :company_owner_person_user}
  let (:owner) { user.employers.first }
  context "as a Person User Contact" do
    let (:contact) { FactoryGirl.build :contact_person_user }
    describe ".create" do
      context "happy flow" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
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
            expect(ContactService.create contact, user, owner).to be_new_record
          end
        end

        context "as a company contact" do
          before do
            @contact = FactoryGirl.create :company_owner_person_user
          end
          it "should be created" do
            expect(ContactService.create @contact, user, owner).not_to be_new_record
          end
        end
      end

      context "if same email with existing contact" do
        before do
          existing = FactoryGirl.create :real_person_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact.email = existing.email
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
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
          @contact = ContactService.create contact, user, owner
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
          @contact = ContactService.create contact, user, owner
        end
        it "should not be created" do
          expect(@contact).to be_new_record
        end

        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end

      context "as a company owner" do
        context "create another owner" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
            @contact = ContactService.create contact, user, owner
          end
          it "should be success" do
            expect(@contact).not_to be_new_record
          end
        end

        context "create another admin" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
            @contact = ContactService.create contact, user, owner
          end
          it "should be success" do
            expect(@contact).not_to be_new_record
          end
        end

        context "create another staff" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
            @contact = ContactService.create contact, user, owner
          end
          it "should be success" do
            expect(@contact).not_to be_new_record
          end
        end
      end

      context "as a company admin" do
        let (:user) {FactoryGirl.create :company_admin_person_user}
        context "create another owner" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
            @contact = ContactService.create contact, user, owner
          end
          it "should not be success" do
            expect(@contact).to be_new_record
          end
        end

        context "create another admin" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
            @contact = ContactService.create contact, user, owner
          end
          it "should not be success" do
            expect(@contact).to be_new_record
          end
        end

        context "create another staff" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
            @contact = ContactService.create contact, user, owner
          end
          it "should be success" do
            expect(@contact).not_to be_new_record
          end
        end
      end

      context "as a staff" do
        let (:user) {FactoryGirl.create :company_staff_person_user}
        context "create another owner" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
            @contact = ContactService.create contact, user, owner
          end
          it "should not be success" do
            expect(@contact).to be_new_record
          end
        end

        context "create another admin" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
            @contact = ContactService.create contact, user, owner
          end
          it "should not be success" do
            expect(@contact).to be_new_record
          end
        end

        context "create another staff" do
          before do
            contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
            @contact = ContactService.create contact, user, owner
          end
          it "should not be success" do
            expect(@contact).to be_new_record
          end
        end
      end
    end

    describe ".update" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
        @contact = ContactService.create contact, user, owner
      end

      context "happy flow" do
        before do
          contact_params = {email: "test@gmail.com"}
          @update_contact = ContactService.update @contact, contact_params, user, owner
        end

        it "should be saved" do
          expect(@contact.email).to eq("test@gmail.com")
        end
      end

      context "if has no relationships with owner" do
        context "as a normal contact" do
          before do

            contact_params = {relationships_attributes: []}
            @contact.relationships.contact_by(owner).each do |r|
              contact_params[:relationships_attributes] << {id: r.id, :"_destroy" => true}
            end
            @contact = ContactService.update @contact, contact_params, user, owner
          end
          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

        context "as a company contact" do
          before do
            @contact = FactoryGirl.create :company_owner_person_user
            contact_params = {relationships_attributes: []}
            @contact.relationships.contact_by(owner).each do |r|
              contact_params[:relationships_attributes] << {id: r.id, :"_destroy" => true}
            end
            @contact = ContactService.update @contact, contact_params, user, owner
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
          @contact = ContactService.update contact, contact_params, user, owner
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
          @contact = ContactService.update contact, contact_params, user, owner
        end
        it "should not be created" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_person_user
          contact_params = {people_attributes: [{id: contact.profile.id, first_name: existing.profile.first_name, last_name: existing.profile.last_name}]}
          @contact = ContactService.update contact, contact_params, user, owner
        end
        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end

      context "update a company owner" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end
          it "should be saved" do
            expect(@contact.email).to eq("test@gmail.com")
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          context "update another owner" do
            before do
              contact_params = {email: "test@gmail.com"}
              @update_contact = ContactService.update @contact, contact_params, user, owner
            end
            it "should not be saved" do
              expect(@contact.errors).not_to be_empty
            end
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end
          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

      end

      context "update a company admin" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end

          it "should be saved" do
            expect(@contact.email).to eq("test@gmail.com")
          end
        end

        context "as a company admin" do
          let (:user) {FactoryGirl.create :company_admin_person_user}
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end

          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end

          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

      end

      context "update a company staff" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
            before do
              contact_params = {email: "test@gmail.com"}
              @update_contact = ContactService.update @contact, contact_params, user, owner
            end

            it "should be saved" do
              expect(@contact.email).to eq("test@gmail.com")
            end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }

          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end

          it "should be saved" do
            expect(@contact.email).to eq("test@gmail.com")
          end
        end

        context "as a company staff" do
          let (:user) { FactoryGirl.create :company_staff_person_user }
          before do
            contact_params = {email: "test@gmail.com"}
            @update_contact = ContactService.update @contact, contact_params, user, owner
          end

          it "should not be saved" do
            expect(@contact.errors).not_to be_empty
          end
        end

      end
    end

    describe ".merge" do
      before do
        contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
      end

      context "into a real user" do
        before do
          @existing = FactoryGirl.create :real_person_user
          @contact = ContactService.merge contact, @existing, user, owner
        end

        it "should merge successfully" do
          expect(@contact).not_to be_nil
          expect(@contact.errors).to be_empty
          expect(@contact.id).to eq(@existing.id)
        end

        it "should merge relationships" do
          expect(@contact.relationships.contact_by(owner)).not_to be_empty
        end

        it "should not merge profile" do
          expect(@contact.profile.first_name).not_to eq(contact.profile.first_name)
          expect(@contact.profile.last_name).not_to eq(contact.profile.last_name)
        end
      end

      context "into a contact user" do
        before do
          @existing = FactoryGirl.create :contact_person_user
          @contact = ContactService.merge contact, @existing, user, owner
        end

        it "should merge successfully" do
          expect(@contact).not_to be_nil
          expect(@contact.errors).to be_empty
          expect(@contact.id).to eq(@existing.id)
        end

        it "should merge relationships" do
          expect(@contact.relationships.contact_by(owner)).not_to be_empty
        end

        it "should merge profile" do
          expect(@contact.profile.first_name).to eq(contact.profile.first_name)
          expect(@contact.profile.last_name).to eq(contact.profile.last_name)
        end
      end

      context "merge a company owner" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should merge successfully" do
            expect(@contact.errors).to be_empty
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should not be successfully" do
            expect(@contact.errors).not_to be_empty
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should not be successfully" do
            expect(@contact.errors).not_to be_empty
          end
        end
      end

      context "merge a company admin" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should merge successfully" do
            expect(@contact.errors).to be_empty
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should not be successfully" do
            expect(@contact.errors).not_to be_empty
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should not be successfully" do
            expect(@contact.errors).not_to be_empty
          end
        end
      end

      context "merge a company staff" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should merge successfully" do
            expect(@contact.errors).to be_empty
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should be successfully" do
            expect(@contact.errors).to be_empty
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @existing = FactoryGirl.create :real_person_user
            @contact = ContactService.merge @contact, @existing, user, owner
          end

          it "should not be successfully" do
            expect(@contact.errors).not_to be_empty
          end
        end
      end

    end

    describe ".destroy" do
      context "as a contact" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
          @contact = ContactService.destroy @contact, user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
        end

        it "should destroy user" do
          expect(PersonUser.exists?(@contact.id)).to be_falsey
        end
      end

      context "as a real user" do
        let (:contact) { FactoryGirl.build :real_person_user }
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
          @contact = ContactService.destroy @contact, user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
          expect(contact.relationships.contact_by(owner)).to be_empty
        end

        it "should not destroy user" do
          expect(PersonUser.exists?(@contact.id)).to be_truthy
        end
      end

      context "as a company contact" do
        before do
          contact_user = FactoryGirl.create :company_user
          contact_user.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact_user, user, owner

          employee_contact = FactoryGirl.create :contact_person_user
          employee_contact.relationships << FactoryGirl.build(:relationship, contact: @contact, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
          @employee_contact = ContactService.create employee_contact, user, owner

          ContactService.destroy @contact, user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
        end

        it "should destroy user" do
          expect(CompanyUser.exists?(@contact.id)).to be_falsey
        end

        it "should destroy employees of company contact" do
          expect(PersonUser.exists?(@employee_contact.id)).to be_falsey
        end
      end

      context "destroy a company owner" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::OWNER)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should be success" do
            expect(PersonUser.exists?(@contact.id)).to be_falsey
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should not be success" do
            expect(PersonUser.exists?(@contact.id)).to be_truthy
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should not be success" do
            expect(PersonUser.exists?(@contact.id)).to be_truthy
          end
        end
      end

      context "destroy a company admin" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::ADMIN)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should be success" do
            expect(PersonUser.exists?(@contact.id)).to be_falsey
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should not be success" do
            expect(PersonUser.exists?(@contact.id)).to be_truthy
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should not be success" do
            expect(PersonUser.exists?(@contact.id)).to be_truthy
          end
        end
      end

      context "destroy a company staff" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::EMPLOYEE, role: Constants::STAFF_ROLES.sample)
          @contact = ContactService.create contact, owner.founders.first, owner
        end

        context "as a company owner" do
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should be success" do
            expect(PersonUser.exists?(@contact.id)).to be_falsey
          end
        end

        context "as a company admin" do
          let (:user) { FactoryGirl.create :company_admin_person_user }
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should be success" do
            expect(PersonUser.exists?(@contact.id)).to be_falsey
          end
        end

        context "as a company staff" do
          let (:user) {FactoryGirl.create :company_staff_person_user}
          before do
            @contact = ContactService.destroy @contact, user, owner
          end

          it "should not be success" do
            expect(PersonUser.exists?(@contact.id)).to be_truthy
          end
        end
      end
    end
  end

  context "as a Company User Contact" do
    let (:contact) { FactoryGirl.build :company_user }
    describe ".create" do
      context "happy flow" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
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
          expect(ContactService.create contact, user, owner).to be_new_record
        end
      end

      context "if duplication" do
        before do
          existing = FactoryGirl.create :real_company_user
          existing.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          contact.profile.company_name = existing.profile.company_name
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
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
          @contact = ContactService.create contact, user, owner
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
        @contact = ContactService.create contact, user, owner
      end

      context "happy flow" do
        before do
          contact_params = {companies_attributes: [{id: contact.profile.id, company_name: "ACME"}]}
          @contact = ContactService.update @contact, contact_params, user, owner
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
          @contact = ContactService.update @contact, contact_params, user, owner
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
          @contact = ContactService.update contact, contact_params, user, owner
        end
        it "should not be created" do
          expect(@contact.errors).not_to be_empty
        end
      end

      context "if user with same info exists" do
        before do
          existing = FactoryGirl.create :real_company_user
          contact_params = {companies_attributes: [{id: contact.profile.id, company_name: existing.profile.company_name}]}
          @contact = ContactService.update contact, contact_params, user, owner
        end
        it "should return existing errors" do
          expect(@contact.errors[:existing]).not_to be_empty
        end
      end
    end

    describe ".destroy" do
      context "as a contact" do
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
          ContactService.destroy @contact, user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
        end

        it "should destroy user" do
          expect(CompanyUser.exists?(@contact.id)).to be_falsey
        end
      end

      context "as a real user" do
        let(:contact) {FactoryGirl.build :real_company_user}
        before do
          contact.relationships << FactoryGirl.build(:relationship, contact: owner, association_type: Constants::CLIENT)
          @contact = ContactService.create contact, user, owner
          @contact = ContactService.destroy @contact, user, owner
        end

        it "should destroy all relationships" do
          expect(owner.relationships.contact_by(@contact)).to be_empty
          expect(@contact.relationships.contact_by(owner)).to be_empty
        end

        it "should not destroy user" do
          expect(CompanyUser.exists?(@contact.id)).to be_truthy
        end
      end
    end
  end

  describe ".import" do
    context "for company contacts" do
      before do
        file = File.open(File.expand_path("../../factories/Sample Companies.xlsx", __FILE__), "r")
        uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: File.basename(file))
        @results = ContactService.import(uploaded_file, user, owner)
      end
      it "should be no errors" do
        expect(@results[:errors]).to be_empty
      end

      it "should saved contacts" do
        expect(@results[:objects]).not_to be_empty
      end
    end

    context "for person contacts" do
      before do
        file = File.open(File.expand_path("../../factories/Sample People.xlsx", __FILE__), "r")
        uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: File.basename(file))
        @results = ContactService.import(uploaded_file, user, owner)
      end
      it "should be no errors" do
        expect(@results[:errors]).to be_empty
      end

      it "should saved contacts" do
        expect(@results[:objects]).not_to be_empty
      end
    end
  end
end
