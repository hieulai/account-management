class UserService
  class << self
    def create(user)
      before_save user
      check_valid user

      if user.errors.empty? && user.skip_existing_checking.blank?
        check_for_existing(user, true)
      end

      if user.errors.empty? && user.save
        after_save(user)
      end
      user
    end

    def update(user, user_params)
      user.attributes = user_params
      before_save user
      check_valid user
      if user.errors.empty? && user.skip_existing_checking.blank?
        check_for_existing(user, true)
      end

      if user.errors.empty? && user.save
        after_save(user)
      end
      user
    end


    def check_valid(user)
      if user.is_a?(PersonUser) && user.email.present?
        existing = PersonUser.reals.has_email(user.email)
        existing = existing.ignores([user.id]) unless user.new_record?
        user.errors[:base] << "This email is already registered" if existing.any?
      end
    end

    def check_for_existing(user, real = false)
      existing = search_for_existings(user, real)
      user.errors[:existing] << "This #{user.type_name} is already existing in system." if existing.any?
    end

    def search_for_existings(user, real = false)
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
        scope = real ? PersonUser.unreals : PersonUser.all
        same_name_contacts = profile.first_name.present? || profile.last_name.present? ? scope.has_name(profile.first_name, profile.last_name) : scope.none
        same_phone_1_contacts = profile.phone_1.present? ? scope.has_phone(profile.phone_1) : scope.none
        same_phone_2_contacts = profile.phone_2.present? ? scope.has_phone(profile.phone_2) : scope.none
        same_website_contacts = profile.website.present? ? scope.has_website(profile.website) : scope.none
        same_email_contacts = user.email.present? ? scope.has_email(user.email) : scope.none
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

    def before_save(user)
    end

    def after_save(user)
    end
  end
end