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

  def is_a_company_contact?(user)
    user.is_a?(PersonUser) &&
        ((user.new_record? && user.relationships.select { |r| r.association_type == Constants::EMPLOYEE && r.contact_id != current_user.id }.any?) ||
            user.relationships.where('association_type = ? AND contact_id != ?', Constants::EMPLOYEE, current_user.id).any?)
  end

  def get_relationship(user, association_type)
    user.new_record? ? user.relationships.select { |r| r.association_type == association_type }.first :
        user.relationships.owned_by(current_user).types(association_type).first
  end

  def existings_for(user)
    ContactService.search_for_existings user, current_user
  end
end
