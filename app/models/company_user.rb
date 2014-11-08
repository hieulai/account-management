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

class CompanyUser < User
  has_many :companies, :foreign_key => :user_id, :dependent => :destroy

  scope :has_company_name, lambda { |company_name| joins(:companies).where('companies.company_name = ?', company_name) }
  scope :has_phone, lambda { |phone| joins(:companies).where('companies.phone_1 = ? OR companies.phone_2 = ? ', phone, phone) }
  scope :has_website, lambda { |website| joins(:companies).where('companies.website = ?', website) }

  accepts_nested_attributes_for :companies, :reject_if => :all_blank, :allow_destroy => true

  def type_name
    "Company"
  end

  def profile
     companies.first
  end

  def display_name
    profile.display_name
  end

  def primary_phone
    profile.primary_phone
  end

  def mailing_list
    employees.map { |u| u.email }.compact.reject(&:empty?)
  end
end
