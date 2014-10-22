module ContactsHelper
  def relationships_for(user)
    array = [Constants::VENDOR, Constants::CLIENT]
    array << Constants::EMPLOYEE if user.is_a? PersonUser
    relationships = []
    array.each do |a|
      relationships << Relationship.new(association_type: a)
    end
    relationships
  end
end
