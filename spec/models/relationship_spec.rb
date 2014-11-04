# == Schema Information
#
# Table name: relationships
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_id       :integer
#  association_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  reflex           :boolean
#  role             :string(255)
#

require 'rails_helper'

RSpec.describe Relationship, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
