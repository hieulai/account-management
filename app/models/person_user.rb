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

class PersonUser < User
  has_many :people, :foreign_key => :user_id, :dependent => :destroy
  accepts_nested_attributes_for :people, :reject_if => :all_blank, :allow_destroy => true

  scope :has_name, lambda { |first_name, last_name| joins(:people).where('people.first_name = ? AND people.last_name = ?', first_name, last_name) }
  scope :has_phone, lambda { |phone|
    if phone.present? && GlobalPhone.validate(phone)
      formatted_phone = GlobalPhone.parse(phone).national_string
      joins(:people).where('people.phone_1 = ? OR people.phone_2 = ? ', formatted_phone, formatted_phone)
    else
      none
    end }

  scope :has_website, lambda { |website| joins(:people).where('people.website = ?', website) }
  scope :reals, -> { where('encrypted_password IS NOT NULL AND encrypted_password != ?', "") }
  scope :unreals, -> { where('encrypted_password IS NULL OR encrypted_password = ?', "") }

  attr_accessor :job_type

  validates :email, presence: true, :unless => Proc.new { |u| u.status == Constants::CONTACT }
  validates :email, uniqueness_without_deleted: :true, :allow_blank => true

  def type_name
    Constants::PERSON
  end

  def profile
    people.first
  end

  def first_name
    profile.first_name
  end

  def last_name
    profile.last_name
  end
end
