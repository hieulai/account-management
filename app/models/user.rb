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

class User < ActiveRecord::Base
  has_many :relationships, :dependent => :destroy
  has_many :target_relationships, class_name: 'Relationship', :foreign_key => 'contact_id', :dependent => :destroy
  has_many :vendor_relationships, -> { :vendors }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :client_relationships, -> { :clients }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :employee_relationships, -> { employees }, class_name: 'Relationship', :foreign_key => 'contact_id'
  has_many :employer_relationships, -> { :employers }, class_name: 'Relationship', :foreign_key => 'contact_id'

  has_many :source_contacts, :class_name => "User", :source => :contact, :through => :relationships
  has_many :contacts, :class_name => "User", :source => :user, :through => :target_relationships
  has_many :vendors, :class_name => "User", :source => :user, :through => :vendor_relationships
  has_many :clients, :class_name => "User", :source => :user, :through => :client_relationships
  has_many :employees, :class_name => "User", :source => :user, :through => :employee_relationships
  has_many :employers, :class_name => "User", :source => :user, :through => :employer_relationships

  accepts_nested_attributes_for :relationships

  def type_name
    "User"
  end

  def display_name
    ""
  end

  def email
    ""
  end

  def primary_phone
    ""
  end
end
