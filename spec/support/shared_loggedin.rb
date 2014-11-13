RSpec.shared_context "shared loggedin" do
  before do
    current_user = FactoryGirl.create(:real_person_user)
    root_user = FactoryGirl.create(:real_company_user)
    current_user.relationships << FactoryGirl.build(:relationship, contact: root_user, association_type: Constants::EMPLOYEE)
    sign_in current_user
    allow(controller).to receive(:root_user).and_return(root_user)
    allow(controller).to receive(:current_user).and_return(current_user)
  end
end