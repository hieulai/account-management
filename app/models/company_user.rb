class CompanyUser < User
  has_many :companies, :foreign_key => :user_id, :dependent => :destroy

  accepts_nested_attributes_for :companies

  def type_name
    "Company"
  end

  def display_name
    companies.first.try(:company_name)
  end

  def email
    companies.first.try(:email)
  end

  def primary_phone
    "#{companies.first.try(:phone_1)} #{companies.first.try(:phone_1_tag)}"
  end
end