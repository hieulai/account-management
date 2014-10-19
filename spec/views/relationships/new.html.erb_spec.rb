require 'rails_helper'

RSpec.describe "relationships/new", :type => :view do
  before(:each) do
    assign(:relationship, Relationship.new())
  end

  it "renders new relationship form" do
    render

    assert_select "form[action=?][method=?]", relationships_path, "post" do
    end
  end
end
