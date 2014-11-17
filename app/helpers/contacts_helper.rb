module ContactsHelper
  def relationships_for(contact)
    relationships = []
    ContactService.relationship_types_for(contact, root_user).each do |a|
      relationships << Relationship.new(association_type: a)
    end
    relationships
  end

  def is_a_company_contact?(contact)
    ContactService.company_contact?(contact, root_user)
  end

  def is_editable?(contact)
    contact.new_record? || (!contact.is_real? && contact.contact_by?(root_user))
  end

  def get_relationship(contact, association_type)
    contact.relationships.select { |r| r.association_type == association_type && r.contact_id == root_user.id }.reject(&:marked_for_destruction?).first
  end

  def existings_for(contact)
    UserService.search_for_existings contact
  end
end
