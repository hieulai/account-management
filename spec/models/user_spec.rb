require 'rails_helper'

describe User do
  it {should respond_to(:first_name)}
  it {should respond_to(:last_name)}
  it {should respond_to(:email)}
  it {should respond_to(:phone_1)}
  it {should respond_to(:phone_2)}
  it {should respond_to(:phone_tag_1)}
  it {should respond_to(:phone_tag_2)}
  it {should respond_to(:website)}
  it {should respond_to(:address_line_1)}
  it {should respond_to(:address_line_2)}
  it {should respond_to(:city)}
  it {should respond_to(:state)}
  it {should respond_to(:zipcode)}

end
