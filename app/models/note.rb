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
#

class Note < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
end
