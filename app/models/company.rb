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
  belongs_to :user

  scope :has_company_name, lambda { |company_name| where('company_name = ?', company_name) }
  scope :has_phone, lambda { |phone| where('phone_1 = ? OR phone_2 = ? ', phone, phone) }
  scope :has_website, lambda { |website| where('website = ?', website) }

  attr_accessor :status

  validates :company_name, presence: true, :uniqueness => {:scope => [:phone_1, :phone_2, :website]}

  def display_name
    company_name
  end

  def primary_phone
    "#{phone_1} #{phone_tag_1}" if phone_1.present?
  end
end
