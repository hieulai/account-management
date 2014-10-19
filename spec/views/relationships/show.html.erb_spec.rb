require 'rails_helper'

RSpec.describe "relationships/show", :type => :view do
  before(:each) do
    @relationship = assign(:relationship, Relationship.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
