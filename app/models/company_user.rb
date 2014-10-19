# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  active       :boolean
#  profile_id   :integer
#  profile_type :string(255)
#  type         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class CompanyUser < User
  has_many :companies, :foreign_key => :user_id, :dependent => :destroy

  accepts_nested_attributes_for :companies

  delegate :company_name, :phone_1, :phone_2, :phone_tag_1, :phone_tag_2, :address_line_1, :address_line_2,
           :city, :state, :zipcode, :website, to: :main_profile, allow_nil: true

  def type_name
    "Company"
  end

  def main_profile
    companies.first
  end

  def display_name
    main_profile.try(:company_name)
  end

  def email
    main_profile.try(:email)
  end

  def primary_phone
    "#{main_profile.try(:phone_1)} #{main_profile.try(:phone_1_tag)}"
  end

end
