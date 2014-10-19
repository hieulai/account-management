module RelationshipsHelper
  def relationship_types(user)
    if user.is_a? CompanyUser
      [[Constants::VENDOR, Relationship.reflex_association_type(Constants::VENDOR)],
       [Constants::CLIENT, Relationship.reflex_association_type(Constants::CLIENT)],
       [Constants::EMPLOYEE, Relationship.reflex_association_type(Constants::EMPLOYEE)]]
    else
      [[Constants::VENDOR, Relationship.reflex_association_type(Constants::VENDOR)],
       [Constants::CLIENT, Relationship.reflex_association_type(Constants::CLIENT)],
       [Constants::EMPLOYER, Relationship.reflex_association_type(Constants::EMPLOYER)]]
    end
  end
end
