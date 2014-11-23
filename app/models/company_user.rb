# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean
#  type                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  deleted_at             :time
#

class CompanyUser < User
  has_many :companies, :foreign_key => :user_id, :dependent => :destroy

  scope :has_company_name, lambda { |company_name| joins(:companies).where('companies.company_name = ?', company_name) }
  scope :has_phone, lambda { |phone|
    if phone.present? && GlobalPhone.validate(phone)
      normalized_phone = GlobalPhone.parse(phone).national_string
      joins(:companies).where('companies.phone_1 = ? OR companies.phone_2 = ? ', normalized_phone, normalized_phone)
    else
      none
    end }

  scope :has_website, lambda { |website|
    if website.present?
      normalized_website = website.sub(/^https?\:\/\//, '').sub(/^www./, '')
      joins(:companies).where('companies.website = ?', normalized_website)
    else
      none
    end
  }

  accepts_nested_attributes_for :companies, :reject_if => :all_blank, :allow_destroy => true

  def type_name
    Constants::COMPANY
  end

  def profile
     companies.first
  end

  def company_name
    profile.company_name
  end
end
