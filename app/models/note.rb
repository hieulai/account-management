# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  content    :text
#  deleted_at :time
#  created_at :datetime
#  updated_at :datetime
#  owner_id   :integer
#

class Note < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
  belongs_to :owner, :class_name => 'User'

  scope :created_by, lambda { |user| where(owner_id: user.id) }
  validates :owner, presence: true
end
