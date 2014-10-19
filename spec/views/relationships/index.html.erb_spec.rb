require 'rails_helper'

RSpec.describe "relationships/index", :type => :view do
  before(:each) do
    assign(:relationships, [
      Relationship.create!(),
      Relationship.create!()
    ])
  end

  it "renders a list of relationships" do
    render
  end
end
