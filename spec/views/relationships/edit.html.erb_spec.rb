require 'rails_helper'

RSpec.describe "relationships/edit", :type => :view do
  before(:each) do
    @relationship = assign(:relationship, Relationship.create!())
  end

  it "renders the edit relationship form" do
    render

    assert_select "form[action=?][method=?]", relationship_path(@relationship), "post" do
    end
  end
end
