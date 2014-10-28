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
#

class Person < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, class: "CompanyUser", foreign_key: :owner_id

  scope :from_real_user, -> { joins(:user).where('users.encrypted_password != ?', "") }
  scope :of_user, lambda { |user_id| where(user_id: user_id) }

  validates :first_name, presence: true

  def display_name
    "#{first_name} #{last_name}"
  end

  def primary_phone
    "#{phone_1} #{phone_tag_1}" if phone_1.present?
  end
end
