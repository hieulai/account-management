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
  include Normalizable
  belongs_to :user

  attr_accessor :status
  trimmed_fields :first_name, :last_name, :phone_1, :phone_2, :phone_tag_1, :phone_tag_2, :address_line_1, :address_line_2, :city, :state, :zipcode, :website
  phony_fields :phone_1, :phone_2
  url_fields :website
  int_fields :zipcode

  validates :first_name, presence: true, :uniqueness_without_deleted => {:scope => [:last_name, :phone_1, :phone_2, :address_line_1, :address_line_2, :city, :state, :zipcode, :website],
                                                                         message: Constants::PERSON_UNIQUENESS}
  validates :last_name, presence: true, :unless => Proc.new { |p| p.status == Constants::CONTACT }

  def display_name
    "#{first_name} #{last_name}"
  end

  def primary_address
    address_line_1.present? ? address_line_1 : address_line_2
  end
end
