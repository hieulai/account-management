class User < ActiveRecord::Base
	has_many :associations
	has_many :contacts, :through => :associations
end
