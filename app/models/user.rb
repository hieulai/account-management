class User < ActiveRecord::Base
  has_many :associations
  has_many :target_associations, class_name: 'Association', :foreign_key => 'contact_id'

  has_many :source_contacts, :class_name => "User", :source => :contact, :through => :associations
  has_many :contacts, :class_name => "User", :source => :user, :through => :target_associations
  has_many :all_contacts, :class_name => "User", :through => [:target_associations, :associations]

  accepts_nested_attributes_for :associations

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
