class Company < ActiveRecord::Base
	belongs_to :company_user, foreign_key: :user_id
end
