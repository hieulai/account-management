# == Schema Information
#
# Table name: companies
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  company_name   :string(255)
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

class Company < ActiveRecord::Base
	belongs_to :company_user, foreign_key: :user_id
end
