# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  active       :boolean
#  profile_id   :integer
#  profile_type :string(255)
#  type         :string(255)
#

class PersonUser < User
  has_many :people, :foreign_key => :user_id, :dependent => :destroy
  accepts_nested_attributes_for :people

  delegate :first_name, :last_name, :phone_1, :phone_2, :phone_tag_1, :phone_tag_2, :address_line_1, :address_line_2,
           :city, :state, :zipcode, :website, to: :main_profile, allow_nil: true

  def type_name
    "Person"
  end

  def main_profile
    people.first
  end

  def display_name
    "#{main_profile.try(:first_name)} #{main_profile.try(:last_name)}"
  end

  def email
    main_profile.try(:email)
  end

  def primary_phone
    "#{main_profile.try(:phone_1)} #{main_profile.try(:phone_1_tag)}"
  end
end
