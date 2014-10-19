require 'rails_helper'

RSpec.describe "associations/new", :type => :view do
  before(:each) do
    assign(:association, Relationship.new(
      :user_id => 1,
      :contact_id => 1
    ))
  end

  it "renders new association form" do
    render

    assert_select "form[action=?][method=?]", associations_path, "post" do

      assert_select "input#association_user_id[name=?]", "association[user_id]"

      assert_select "input#association_contact_id[name=?]", "association[contact_id]"
    end
  end
end
