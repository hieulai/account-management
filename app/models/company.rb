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
#  deleted_at     :time
#

class Company < ActiveRecord::Base
  acts_as_paranoid
  include Normalizable

  belongs_to :user

  attr_accessor :status
  trimmed_fields :company_name, :phone_1, :phone_2, :phone_tag_1, :phone_tag_2, :address_line_1, :address_line_2, :city, :state, :zipcode, :website
  phony_fields :phone_1, :phone_2
  url_fields :website

  validates :company_name, presence: true
  validates :company_name, :uniqueness_without_deleted => {scope: [:phone_1, :phone_2, :address_line_1, :address_line_2, :city, :state, :zipcode, :website],
                                                           message: Constants::COMPANY_UNIQUENESS}

  def display_name
    company_name
  end

  def primary_address
    address_line_1.present? ? address_line_1 : address_line_2
  end
end
