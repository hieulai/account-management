# == Schema Information
#
# Table name: associations
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_id       :integer
#  association_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Association < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id'
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'

  def update_reflection

  end

  def destroy_reflection

  end
end
