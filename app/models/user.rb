class User < ActiveRecord::Base
  has_many :associations
  has_many :contacts, :through => :associations
  belongs_to :profile, polymorphic: true

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
