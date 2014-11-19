RSpec.shared_examples "a user" do
  subject { FactoryGirl.create :user }
  describe "User" do

    describe "Attributes" do
      it { should respond_to(:type) }
      it { should respond_to(:email) }
      it { should respond_to(:skip_existing_checking) }
      it { should respond_to(:status) }
      it { should respond_to(:profile) }
      it { should respond_to(:type_name) }
      it { should respond_to(:display_name) }
      it { should respond_to(:primary_phone) }

      describe "#is_real?" do
        context "as a Person User has password" do
          subject { FactoryGirl.create :real_person_user }
          it { expect(subject.is_real?).to be_truthy }
        end

        context "as a Company User has founder" do
          subject { FactoryGirl.create :real_company_user }
          it { expect(subject.is_real?).to be_truthy }
        end

        context "as a Contact Person User" do
          subject { FactoryGirl.create :contact_person_user }
          it { expect(subject.is_real?).to be_falsey }
        end

        context "as a Contact Company User" do
          subject { FactoryGirl.create :company_user }
          it { expect(subject.is_real?).to be_falsey }
        end
      end

      describe "#is_created_by?" do
        subject { FactoryGirl.create :user }
        before do
          @creator = FactoryGirl.create :user
          @other = FactoryGirl.create :user
          subject.relationships << FactoryGirl.create(:belong_relationship, user: subject, contact: @creator)
        end
        it "if by creator should be true" do
          expect(subject.is_created_by?(@creator)).to be_truthy
        end
        it "if by other should be false" do
          expect(subject.is_created_by?(@other)).to be_falsey
        end
      end

      describe "#contact_by?" do
        subject { FactoryGirl.create :user }
        before do
          @creator = FactoryGirl.create :user
          @other = FactoryGirl.create :user
          subject.relationships << FactoryGirl.create(:relationship, user: subject, contact: @creator)
        end
        it "if by creator should be true" do
          expect(subject.contact_by?(@creator)).to be_truthy
        end
        it "if by other should be false" do
          expect(subject.contact_by?(@other)).to be_falsey
        end
      end
    end

    describe "Associations" do
      it { expect(subject).to have_many :notes }
      it { expect(subject).to have_many :relationships }
      it { expect(subject).to have_many :belong_relationships }
      it { expect(subject).to have_many :source_employee_relationships }
      it { expect(subject).to have_many :founders_relationships }

      it { expect(subject).to have_many :target_relationships }
      it { expect(subject).to have_many :vendor_relationships }
      it { expect(subject).to have_many :client_relationships }
      it { expect(subject).to have_many :employee_relationships }
      it { expect(subject).to have_many :employer_relationships }
      it { expect(subject).to have_many :owners_relationships }

      it { expect(subject).to have_many :source_contacts }
      it { expect(subject).to have_many :creators }
      it { expect(subject).to have_many :founders }
      it { expect(subject).to have_many :contacts }
      it { expect(subject).to have_many :company_contacts }
      it { expect(subject).to have_many :person_contacts }
      it { expect(subject).to have_many :vendors }
      it { expect(subject).to have_many :clients }
      it { expect(subject).to have_many :employees }
      it { expect(subject).to have_many :employers }
      it { expect(subject).to have_many :owners }
    end

    describe "Scopes" do
      describe "companies" do
        subject { FactoryGirl.create :company_user }
        it { expect(User.companies).to include(subject) }
      end

      describe "people" do
        subject { FactoryGirl.create :person_user }
        it { expect(User.people).to include(subject) }
      end

      describe "has_email" do
        subject { FactoryGirl.create :user, email: "test@gmail.com" }
        it { expect(User.has_email("test@gmail.com")).to include(subject) }
      end

      describe "ignores" do
        subject { FactoryGirl.create :user }
        it { expect(User.ignores(subject.id)).not_to include(subject) }
      end
    end
  end
end