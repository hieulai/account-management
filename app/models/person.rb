# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  first_name     :string(255)
#  last_name      :string(255)
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

class Person < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user

  attr_accessor :status
  validates :first_name, presence: true, :uniqueness_without_deleted => {:scope => [:last_name, :phone_1, :phone_2, :website]}
  validates :last_name, presence: true, :unless => Proc.new { |p| p.status == Constants::CONTACT }

  def display_name
    "#{first_name} #{last_name}"
  end

  def primary_phone
    "#{phone_1} #{phone_tag_1}" if phone_1.present?
  end

  def primary_address
    address_line_1.present? ? address_line_1 : address_line_2
  end
end
