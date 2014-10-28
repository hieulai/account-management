# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  first_name     :string(255)
#  last_name      :string(255)
#  phone_1        :string(255)
#  phone_2        :string(255)
#  phone_tag_1    :string(255)
#  phone_tag_2    :string(255)
#  address_line_1 :string(255)
#  address_line_2 :string(255)
#  city           :string(255)
#  state          :string(255)
#  zipcode        :string(255)
#  website        :string(255)
#  user_id        :integer
#

require 'rails_helper'

RSpec.describe Person, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
