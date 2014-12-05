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
#  role             :string(255)
#  deleted_at       :time
#

class Relationship < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user, :foreign_key => :user_id
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id

  scope :contact_by, lambda { |user| where(contact_id: user.id) }
  scope :ignores, lambda { |ids| where('contact_id NOT IN (?)', ids) }

  scope :types, lambda { |type| where(association_type: type) }
  scope :vendors, -> { types Constants::VENDOR }
  scope :clients, -> { types Constants::CLIENT }
  scope :employees, -> { types Constants::EMPLOYEE }
  scope :employers, -> { types Constants::EMPLOYER }
  scope :type_having, -> { types Constants::HAS }
  scope :type_belong, -> { types Constants::BELONG }
  scope :owners, -> { types(Constants::EMPLOYER).where(role: Constants::OWNER) }

  validates :contact, :association_type, presence: true
  validates :association_type, :inclusion => {:in => Constants::ASSOCIATION_TYPES}

  after_create :create_reflection, :unless => Proc.new { |r| r.reflex? }
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
        when Constants::HAS
          Constants::BELONG
        else
          Constants::HAS
      end
    end
  end

  def is?(association_type)
    self.association_type.try(:downcase) == association_type.to_s.downcase
  end

  def reflection
    Relationship.where(reflection_attributes).first
  end

  def create_reflection
    Relationship.create(reflection_attributes.merge(reflex: true))
  end

  def destroy_reflection
    Relationship.where(reflection_attributes.merge(user_id: contact_id_was)).destroy_all
  end

  private
  def reflection_attributes
    {user_id: contact_id, contact_id: user_id, role: role, association_type: Relationship.reflex_association_type(association_type)}
  end
end
