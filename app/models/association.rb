class Association < ActiveRecord::Base
	belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
	belongs_to :contact, :class_name => "User", :foreign_key => 'contact_id'
end
