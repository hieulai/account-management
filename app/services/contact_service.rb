class ContactService

  class << self

    def create(new_contact, owner)
      before_save(new_contact, owner)
      check_valid(new_contact, owner)
      check_for_relationships(new_contact)
      check_for_duplication(new_contact, owner)

      if new_contact.errors.empty? && new_contact.skip_existing_checking.blank?
        UserService.check_for_existing(new_contact)
      end

      if new_contact.errors.empty? && new_contact.save
        after_save(new_contact, owner)
      end
      new_contact
    end

    def update(contact, contact_params, owner)
      contact.attributes = contact_params

      before_save(contact, owner)
      check_valid(contact, owner)
      check_for_relationships(contact)
      check_for_duplication(contact, owner)

      if contact.errors.empty? && contact.skip_existing_checking.blank?
        UserService.check_for_existing(contact)
      end

      if contact.errors.empty? && contact.save
        after_save(contact, owner)
      end
      contact
    end

    def destroy(contact, owner)
      contact.destroy unless contact.is_real?
      contact.relationships.contact_by(owner).destroy_all
      owner.relationships.contact_by(contact).destroy_all
    end

    def check_valid(contact, owner)
      contact.valid? if contact.email.present? && owner.contacts.has_email(contact.email)
    end

    def check_for_relationships(contact)
      if contact.relationships.reject(&:marked_for_destruction?).reject { |r| r.association_type == Constants::BELONG }.empty?
        contact.errors[:base] << "At least 1 relationship type is required for all contacts."
      end
    end

    def check_for_duplication(contact, owner)
      duplication = []
      profile = contact.profile
      if contact.is_a? CompanyUser
        same_name_contacts = profile.company_name.present? ? owner.company_contacts.has_company_name(profile.company_name) : CompanyUser.none
        same_name_contacts = same_name_contacts.where.not(id: contact.id) unless contact.new_record?
        duplication = same_name_contacts
      else
        same_name_contacts = profile.first_name.present? || profile.last_name.present? ? owner.person_contacts.has_name(profile.first_name, profile.last_name) : PersonUser.none
        same_name_contacts = same_name_contacts.where.not(id: contact.id) unless contact.new_record?
        duplication = same_name_contacts
      end
      contact.errors[:base] << "This #{contact.type_name} is already one of your contacts." if duplication.any?
    end

    private
    def before_save(contact, owner)
      contact.status = Constants::CONTACT
      contact.send(:"#{contact.type_name.underscore.pluralize}").each do |p|
        p.status = Constants::CONTACT
      end
    end

    def after_save(contact, owner)
      create_default_relationships(contact, owner)
    end

    def create_default_relationships(contact, owner)
      # Identify the contact's owner
      contact.relationships.where(:association_type => Constants::BELONG, :contact_id => owner.id).first_or_create
    end
  end
end