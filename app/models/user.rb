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

class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :notes, dependent: :destroy
  has_many :created_notes, class_name: 'Note', :foreign_key => 'owner_id', :dependent => :destroy
  has_many :relationships, :dependent => :destroy
  has_many :belong_relationships, -> { type_belong }, class_name: 'Relationship', :dependent => :destroy
  has_many :source_employee_relationships, -> { employees }, class_name: 'Relationship', :dependent => :destroy
  has_many :founders_relationships, -> { owners }, class_name: 'Relationship', :dependent => :destroy

  has_many :target_relationships, class_name: 'Relationship', :foreign_key => 'contact_id', :dependent => :destroy
  has_many :vendor_relationships, -> { vendors }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :client_relationships, -> { clients }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :employee_relationships, -> { employees }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :employer_relationships, -> { employers }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :owners_relationships, -> { owners }, class_name: 'Relationship', :foreign_key => 'contact_id'

  has_many :source_contacts, :class_name => "User", :source => :contact, :through => :relationships
  has_many :creators, class_name: 'User', :source => :contact, :through => :belong_relationships
  has_many :founders, class_name: 'User', :source => :contact, :through => :founders_relationships
  has_many :contacts, -> { uniq }, :class_name => "User", :source => :user, :through => :target_relationships
  has_many :company_contacts, -> { companies.uniq }, :class_name => "CompanyUser", :source => :user, :through => :target_relationships
  has_many :person_contacts, -> { people.uniq }, :class_name => "PersonUser", :source => :user, :through => :target_relationships
  has_many :vendors, :class_name => "User", :source => :user, :through => :vendor_relationships
  has_many :clients, :class_name => "User", :source => :user, :through => :client_relationships
  has_many :employees, :class_name => "User", :source => :user, :through => :employee_relationships
  has_many :employers, :class_name => "User", :source => :user, :through => :employer_relationships
  has_many :owners, :class_name => "User", :source => :user, :through => :owners_relationships

  scope :companies, -> { where type: "CompanyUser" }
  scope :people, -> { where type: "PersonUser" }
  scope :employee_people, -> { people.joins(:relationships).where("relationships.association_type = ?", Constants::EMPLOYEE) }
  scope :non_employee_people, -> { people.where('users.id NOT IN (?)', employee_people.map(&:id)) }
  scope :has_email, lambda { |email| where('email = ?', email) }
  scope :ignores, lambda { |ids| where('users.id NOT IN (?)', ids) }

  accepts_nested_attributes_for :relationships, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :notes, :reject_if => :all_blank, :allow_destroy => true
  attr_accessor :skip_existing_checking, :status

  devise :database_authenticatable, :registerable, :recoverable

  def type_name
    "User"
  end

  def profile
  end

  def display_name
    profile.try(:display_name)
  end

  def city
    profile.try(:city)
  end

  def state
    profile.try(:state)
  end

  def zipcode
    profile.try(:zipcode)
  end

  def is_real?
    (is_a?(PersonUser) && encrypted_password != "")|| (founders.select { |c| c.is_real? }.any?)
  end

  def is?(association_type)
    relationships.select { |r| r.is? association_type }.any?
  end

  def act_as?(*roles)
    relationships.select { |r| r.is?(:employee) && roles.include?(r.role) }.any?
  end

  def act_as_owner?
    act_as?(Constants::OWNER)
  end

  def act_as_admin?
    act_as?(Constants::OWNER, Constants::ADMIN)
  end

  def is_created_by?(user)
    new_record? || creators.include?(user)
  end

  def contact_by?(user)
    relationships.contact_by(user).any?
  end

  def company
    employers.first
  end

  def role_in_company
    relationships.select { |r| r.is? :employee }.first.role rescue Constants::OWNER
  end
end
