# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean
#  profile_id             :integer
#  profile_type           :string(255)
#  type                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#

class PersonUser < User
  has_many :people, :foreign_key => :user_id, :dependent => :destroy
  accepts_nested_attributes_for :people, :reject_if => :all_blank, :allow_destroy => true

  scope :has_name, lambda { |first_name, last_name| joins(:companies).where('people.first_name = ? AND people.last_name = ?', first_name, last_name) }

  def type_name
    "Person"
  end

  def profile
    people.first
  end

  def display_name
    profile.display_name
  end

  def primary_phone
    profile.primary_phone
  end
end
