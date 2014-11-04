module ContactsHelper
  def relationships_for(user)
    array = [Constants::VENDOR, Constants::CLIENT]
    array << Constants::EMPLOYEE if user.is_a?(PersonUser) && root_user.is_a?(CompanyUser)
    array << Constants::EMPLOYER if user.is_a?(CompanyUser) && !root_user.is_a?(CompanyUser)
    relationships = []
    array.each do |a|
      relationships << Relationship.new(association_type: a)
    end
    relationships
  end

  def is_a_company_contact?(user)
    user.is_a?(PersonUser) &&
        (user.new_record? && user.relationships.select { |r| r.association_type == Constants::EMPLOYEE && r.contact_id != root_user.id }.any? ||
            user.relationships.where('association_type = ? and contact_id != ?', Constants::EMPLOYEE, root_user.id).any?)
  end

  def get_relationship(user, association_type)
    user.new_record? ? user.relationships.select { |r| r.association_type == association_type }.first :
        user.relationships.contact_by(root_user).types(association_type).first
  end

  def existings_for(user)
    UserService.search_for_existings user
  end
end
