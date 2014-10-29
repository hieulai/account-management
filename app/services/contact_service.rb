class ContactService

  class << self

    def create(new_user, owner)
      check_for_relationships(new_user)
      check_for_duplication(new_user, owner)

      if new_user.errors.empty? && new_user.skip_existing_checking.blank?
        check_for_existing(new_user, owner)
      end

      if new_user.errors.empty? && new_user.save
        after_save(new_user, owner)
      end
      new_user
    end

    def update(user, user_params, owner)
      user.attributes = user_params
      check_for_relationships(user)
      check_for_duplication(user, owner)

      if user.errors.empty? && user.skip_existing_checking.blank?
        check_for_existing(user, owner)
      end

      if user.errors.empty? && user.save
        after_save(user, owner)
      end
      user
    end

    def destroy(user, owner)
      user.destroy if user.is_created_by? owner
      user.relationships.owned_by(owner).destroy_all
      owner.relationships.owned_by(user).destroy_all
    end

    def check_for_relationships(user)
      if user.relationships.empty?
        user.errors[:base] << "Relationships are required"
      end
    end

    def check_for_duplication(user, owner)
      duplication = []
      profile = user.profile
      if user.is_a? CompanyUser
        same_name_contacts = profile.company_name.present? ? owner.company_contacts.has_company_name(profile.company_name) : CompanyUser.none
        same_name_contacts = same_name_contacts.where.not(id: user.id) unless user.new_record?
        duplication = same_name_contacts
      else
        same_name_contacts = profile.first_name.present? || profile.last_name.present? ? owner.person_contacts.has_name(profile.first_name, profile.last_name) : PersonUser.none
        same_name_contacts = same_name_contacts.where.not(id: user.id) unless user.new_record?
        duplication = same_name_contacts
      end
      user.errors[:base] << "This #{user.type_name} is already one of your contacts." if duplication.any?
    end

    def check_for_existing(user, owner)
      existing = search_for_existings(user, owner)
      user.errors[:existing] << "This company is already existing in system." if existing.any?
    end

    def search_for_existings(user, owner)
      existings = []
      profile = user.profile
      if user.is_a? CompanyUser
        same_name_contacts = CompanyUser.has_company_name(profile.company_name)
        same_phone_1_contacts = profile.phone_1.present? ? CompanyUser.has_phone(profile.phone_1) : CompanyUser.none
        same_phone_2_contacts = profile.phone_2.present? ? CompanyUser.has_phone(profile.phone_2) : CompanyUser.none
        same_website_contacts = profile.website.present? ? CompanyUser.has_website(profile.website) : CompanyUser.none
        unless user.new_record?
          same_name_contacts = same_name_contacts.where.not(id: user.id)
          same_phone_1_contacts = same_phone_1_contacts.where.not(id: user.id)
          same_phone_2_contacts = same_phone_2_contacts.where.not(id: user.id)
          same_website_contacts = same_website_contacts.where.not(id: user.id)
        end
        existings = same_name_contacts + same_phone_1_contacts + same_phone_2_contacts + same_website_contacts
      else
        same_name_contacts = profile.first_name.present? || profile.last_name.present? ? PersonUser.has_name(profile.first_name, profile.last_name) : PersonUser.none
        same_phone_1_contacts = profile.phone_1.present? ? PersonUser.has_phone(profile.phone_1) : PersonUser.none
        same_phone_2_contacts = profile.phone_2.present? ? PersonUser.has_phone(profile.phone_2) : PersonUser.none
        same_website_contacts = profile.website.present? ? PersonUser.has_website(profile.website) : PersonUser.none
        same_email_contacts = user.email.present? ? PersonUser.has_email(user.email) : PersonUser.none
        unless user.new_record?
          same_name_contacts = same_name_contacts.where.not(id: user.id)
          same_phone_1_contacts = same_phone_1_contacts.where.not(id: user.id)
          same_phone_2_contacts = same_phone_2_contacts.where.not(id: user.id)
          same_website_contacts = same_website_contacts.where.not(id: user.id)
          same_email_contacts = same_email_contacts.where.not(id: user.id)
        end
        existings = same_name_contacts + same_phone_1_contacts + same_phone_2_contacts + same_website_contacts + same_email_contacts
      end
      existings.uniq
    end

    private
    def after_save(user, owner)
      create_default_relationships(user, owner)
    end

    def create_default_relationships(user, owner)
      # Identify the contact's owner
      user.relationships.create(:association_type => Constants::CONTACT, :contact_id => owner.id)
    end
  end
end