require 'rails_helper'

RSpec.describe "associations/show", :type => :view do
  before(:each) do
    @association = assign(:association, Association.create!(
      :user_id => 1,
      :contact_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
