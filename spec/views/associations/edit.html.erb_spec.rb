require 'rails_helper'

RSpec.describe "associations/edit", :type => :view do
  before(:each) do
    @association = assign(:association, Association.create!(
      :user_id => 1,
      :contact_id => 1
    ))
  end

  it "renders the edit association form" do
    render

    assert_select "form[action=?][method=?]", association_path(@association), "post" do

      assert_select "input#association_user_id[name=?]", "association[user_id]"

      assert_select "input#association_contact_id[name=?]", "association[contact_id]"
    end
  end
end
