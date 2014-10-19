require 'rails_helper'

RSpec.describe "associations/index", :type => :view do
  before(:each) do
    assign(:relationships, [
      Relationship.create!(
        :user_id => 1,
        :contact_id => 2
      ),
      Relationship.create!(
        :user_id => 1,
        :contact_id => 2
      )
    ])
  end

  it "renders a list of associations" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
