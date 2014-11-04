class ContactService

  class << self

    def create(new_user, owner)
      before_save(new_user, owner)
      check_for_relationships(new_user)
      check_for_duplication(new_user, owner)

      if new_user.errors.empty? && new_user.skip_existing_checking.blank?
        UserService.check_for_existing(new_user)
      end

      if new_user.errors.empty? && new_user.save
        after_save(new_user, owner)
      end
      new_user
    end

    def update(user, user_params, owner)
      user.attributes = user_params

      before_save(user, owner)
      check_for_relationships(user)
      check_for_duplication(user, owner)

      if user.errors.empty? && user.skip_existing_checking.blank?
        UserService.check_for_existing(user)
      end

      if user.errors.empty? && user.save
        after_save(user, owner)
      end
      user
    end

    def destroy(user, owner)
      user.destroy if user.is_created_by? owner
      user.relationships.contact_by(owner).destroy_all
      owner.relationships.contact_by(user).destroy_all
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

    private
    def before_save(user, owner)
      user.status = Constants::CONTACT
      user.send(:"#{user.type_name.underscore.pluralize}").each do |p|
        p.status = Constants::CONTACT
      end
    end

    def after_save(user, owner)
      create_default_relationships(user, owner)
    end

    def create_default_relationships(user, owner)
      # Identify the contact's owner
      user.relationships.where(:association_type => Constants::BELONG, :contact_id => owner.id).first_or_create
    end
  end
end