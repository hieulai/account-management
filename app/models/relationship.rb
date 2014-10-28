# == Schema Information
#
# Table name: relationships
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_id       :integer
#  association_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  reflex           :boolean
#

class Relationship < ActiveRecord::Base

  belongs_to :user, :foreign_key => :user_id
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id

  scope :owned_by, lambda { |user| where(contact_id: user.id) }
  scope :types, lambda { |type| where(association_type: type) }
  scope :vendors, -> { types Constants::VENDOR }
  scope :clients, -> { types Constants::CLIENT }
  scope :employees, -> { types Constants::EMPLOYEE }
  scope :employers, -> { types Constants::EMPLOYER }

  after_save :destroy_reflection
  after_save :update_reflection, :unless => Proc.new { |r| r.reflex? }
  after_destroy :destroy_reflection

  class << self
    def reflex_association_type(type)
      case type
        when Constants::VENDOR
          Constants::CLIENT
        when Constants::CLIENT
          Constants::VENDOR
        when Constants::EMPLOYER
          Constants::EMPLOYEE
        when Constants::EMPLOYEE
          Constants::EMPLOYER
        else
          Constants::UNDEFINED
      end
    end
  end

  [Constants::VENDOR, Constants::CLIENT, Constants::EMPLOYEE, Constants::UNDEFINED].each do |name|
    define_method("is_a_#{name.underscore}?") do
      association_type == name
    end
  end

  def reflection(type)
    attr = {user_id: contact_id, contact_id: user_id}
    Relationship.where attr.merge(association_type: Relationship.reflex_association_type(type))
  end

  def update_reflection
    reflection(association_type).first_or_create(reflex: true)
  end

  def destroy_reflection
    reflection(association_type_was).destroy_all
  end
end
