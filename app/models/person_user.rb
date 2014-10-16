class PersonUser < User
  has_many :people, :foreign_key => :user_id, :dependent => :destroy
  accepts_nested_attributes_for :people

  def type_name
    "Person"
  end

  def display_name
    "#{people.first.try(:first_name)} #{people.first.try(:last_name)}"
  end

  def email
    people.first.try(:email)
  end

  def primary_phone
    "#{people.first.try(:phone_1)} #{people.first.try(:phone_1_tag)}"
  end
end