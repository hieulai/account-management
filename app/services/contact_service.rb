class ContactService

  class << self

    def create(new_contact, current_user, owner)
      authorize(new_contact, current_user)

      check_valid(new_contact, owner)
      check_for_relationships(new_contact, owner)
      check_for_duplication(new_contact, owner)

      if new_contact.errors.empty? && new_contact.skip_existing_checking.blank?
        UserService.check_for_existing(new_contact)
      end

      before_save(new_contact, owner)
      if new_contact.errors.empty? && new_contact.save
        after_save(new_contact, owner)
        new_contact.reload
      end
      new_contact
    end

    def update(contact, contact_params, current_user, owner)
      authorize(contact, current_user)

      contact.attributes = contact_params
      check_valid(contact, owner)
      check_for_relationships(contact, owner)
      check_for_duplication(contact, owner)

      if contact.errors.empty? && contact.skip_existing_checking.blank?
        UserService.check_for_existing(contact)
      end

      before_save(contact, owner)
      if contact.errors.empty? && contact.save
        after_save(contact, owner)
        contact.reload
      end
      contact
    end

    def merge(contact, updated_contact, current_user, owner)
      authorize(contact, current_user)
      return contact if contact.errors.any?

      before_save(updated_contact, owner)
      attributes = {relationships_attributes: [], notes_attributes: [] }

      merged_relationships = contact.relationships
      merged_relationships = merged_relationships.contact_by(owner).reject { |r| r.association_type == Constants::BELONG } unless contact.new_record?
      merged_relationships.each do |r|
        attributes[:relationships_attributes] << {association_type: r.association_type, contact_id: r.contact_id, role: r.role, id: updated_contact.relationships.contact_by(r.contact).types(r.association_type).first.try(:id)}
      end

      notes_attributes = contact.notes
      notes_attributes = notes_attributes.created_by(owner) unless contact.new_record?
      notes_attributes.each do |n|
        attributes[:notes_attributes] << {content: n.content, owner_id: n.owner_id, id: updated_contact.notes.created_by(owner).first.try(:id)}
      end

      updated_time = contact.new_record? ? Time.now : contact.profile.updated_at
      if !updated_contact.is_real? && (updated_time > updated_contact.profile.updated_at)
        profile_attributes = contact.profile.attributes.delete_if { |k, v| v.blank? || %w(deleted_at created_at updated_at user_id).include?(k) }
        profile_attributes['id'] = updated_contact.profile.id
        attributes[:"#{updated_contact.type_name.underscore.pluralize}_attributes"] = profile_attributes
      end

      if updated_contact.update_attributes(attributes)
        contact.destroy unless contact.new_record?
        updated_contact.reload
        after_save(updated_contact, owner)
      end
      updated_contact
    end

    def import(file, current_user, owner)
      errors = []
      objects = []
      spreadsheet = open_spreadsheet(file)

      if spreadsheet.nil? || spreadsheet.first_row.nil?
        objects << "There is no data in file"
        return {errors: errors, objects: objects}
      end

      header = spreadsheet.row(1).map! { |c| c.downcase.strip.tr(" ","_") }
      if header[0] == Constants::COMPANY_NAME
        type = Constants::COMPANY
      elsif  header[0] == Constants::FIRST_NAME
        type = Constants::PERSON
      else
        objects << "Invalid file format"
        return {errors: errors, objects: objects}
      end

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        contact = process_import(row, type, current_user, owner)
        if contact.errors.any?
          errors << "Importing Error at line #{i}: #{contact.errors.full_messages.join(". ")}"
        else
          after_save(contact, owner)
          objects << contact
        end
      end
      {errors: errors, objects: objects}
    end

    def destroy(contact, current_user, owner)
      authorize(contact, current_user)
      return contact if contact.errors.any?

      contact.relationships.contact_by(owner).destroy_all
      owner.relationships.contact_by(contact).destroy_all
      unless contact.is_real?
        if contact.is_a? CompanyUser
          contact.employees.each do |c|
            c.relationships.contact_by(contact).destroy_all
            contact.relationships.contact_by(c).destroy_all
            destroy(c, current_user, owner)
          end
        end
        contact.reload
        contact.destroy unless contact.relationships.any?
      end
      contact
    end

    def search (query, options = {}, current_user, owner)
      search = Relationship.search {
        fulltext query
        with(:contact_id, owner.id)
        without(:user_id, current_user.id)
        with(:association_type, options[:association_type]) if options[:association_type]
        group :user_id_str
        paginate :page => options[:page], :per_page => Kaminari.config.default_per_page
        order_by options[:sort_field].to_sym, options[:sort_dir].to_sym if options[:sort_field] && options[:sort_dir]
      }
      search.group(:user_id_str).groups
    end

    def check_valid(contact, owner)
      if contact.is_a?(PersonUser) && contact.email.present?
        existing = owner.contacts.has_email(contact.email)
        existing = existing.ignores([contact.id]) unless contact.new_record?
        contact.errors[:base] << "This email is already registered" if existing.any?
      end
    end

    def check_for_relationships(contact, owner)
      if !company_contact?(contact, owner) && contact.relationships.reject(&:marked_for_destruction?).reject { |r| r.association_type == Constants::BELONG || r.contact_id != owner.id }.empty?
        contact.errors[:base] << "At least 1 relationship type is required for all contacts."
      end
    end

    def check_for_duplication(contact, owner)
      duplications = search_for_duplications(contact, owner)
      contact.errors[:base] << "This #{contact.type_name} is already one of your contacts." if duplications.any?
    end

    def company_contact?(contact, owner)
      contact.is_a?(PersonUser) && contact.relationships.select { |r| r.association_type == Constants::EMPLOYEE && r.contact_id != owner.id }.any?
    end

    def relationship_types_for(contact, owner)
      array = [Constants::VENDOR, Constants::CLIENT]
      array << Constants::EMPLOYER if contact.is_a?(CompanyUser) && !owner.is_a?(CompanyUser)
      array
    end

    def search_for_duplications(contact, owner)
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
      duplication
    end

    def note_for(user, owner)
      user.notes.created_by(owner).first_or_initialize
    end

    def relationship_names_for(contact, owner)
       names = []
       contact.relationships.contact_by(owner).reject { |r| r.is? :belong }.each do |r|
         names << r.association_type
       end
      names.join(", ")
    end

    def employment_status_for(contact, owner)
      contact.employers.first.try(:display_name) || Constants::SELF_EMPLOYED_STATUS
    end

    private

    def authorize(contact, user)
      employee_relationship = contact.relationships.select { |r| r.is?(:employee) && (r.contact == user.employers.first) }.first
      if employee_relationship.present? && !authorize_roles(user, employee_relationship.role)
        contact.errors[:base] << Constants::PERMISSION_VIOLATION
      end
    end

    def authorize_roles(user, for_role)
      case for_role
        when Constants::OWNER, Constants::ADMIN
          user.act_as_owner?
        else
          user.act_as_admin?
      end
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::Csv.new(file.path,nil)
        when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
        else nil
      end
    end

    def process_import(row, type, current_user, owner)
      contact_params = initiate_contact_params(row, type, owner)
      contact = User.new(contact_params)
      check_for_relationships(contact, owner)
      authorize(contact, current_user)

      return contact if contact.errors.any?

      duplications = search_for_duplications(contact, owner)
      return merge(contact, duplications.first, current_user, owner) if duplications.any?

      existings = UserService.search_for_existings(contact)
      return merge(contact, existings.first, current_user, owner) if existings.any?

      contact.save
      contact
    end

    def initiate_contact_params(row, type, owner)
      contact_params = {relationships_attributes: []}
      if row[Constants::RELATIONSHIPS].present?
        row[Constants::RELATIONSHIPS].split(",").map(&:strip).each do |r|
          contact_params[:relationships_attributes] << {association_type: r, contact_id: owner.id}
        end
      end

      if type == Constants::PERSON
        contact_params.merge!(type: "PersonUser", email: row[Constants::EMAIL].to_s,
                              people_attributes: [{first_name: row[Constants::FIRST_NAME].to_s,
                                                   last_name: row[Constants::LAST_NAME].to_s,
                                                   address_line_1: row[Constants::ADDRESS_LINE_1].to_s,
                                                   address_line_2: row[Constants::ADDRESS_LINE_2].to_s,
                                                   city: row[Constants::CITY].to_s,
                                                   state: row[Constants::STATE].to_s,
                                                   zipcode: row[Constants::ZIPCODE].to_s,
                                                   phone_1: row[Constants::PHONE].to_s,
                                                   phone_tag_1: row[Constants::PHONE_TAG].to_s}],
                              notes_attributes: [{owner_id: owner.id, content: row[Constants::NOTES].to_s}])
        if row[Constants::EMPLOYMENT_STATUS].present? && row[Constants::EMPLOYMENT_STATUS].to_s != Constants::SELF_EMPLOYED_STATUS
          duplications = search_for_duplications(CompanyUser.new({companies_attributes: [{company_name: row[Constants::EMPLOYMENT_STATUS].to_s}]}), owner)
          if duplications.any?
            contact_params[:relationships_attributes] = [{association_type: Constants::EMPLOYEE, contact_id: duplications.first.id}]
          end
        end
      else
        contact_params.merge!(type: "CompanyUser",
                              companies_attributes: [{company_name: row[Constants::COMPANY_NAME].to_s,
                                                      address_line_1: row[Constants::ADDRESS_LINE_1].to_s,
                                                      address_line_2: row[Constants::ADDRESS_LINE_2].to_s,
                                                      city: row[Constants::CITY].to_s,
                                                      state: row[Constants::STATE].to_s,
                                                      zipcode: row[Constants::ZIPCODE].to_s,
                                                      phone_1: row[Constants::PHONE].to_s,
                                                      phone_tag_1: row[Constants::PHONE_TAG].to_s}],
                              notes_attributes: [{owner_id: owner.id, content: row[Constants::NOTES].to_s}])
      end
      contact_params
    end

    def before_save(contact, owner)
      contact.status = Constants::CONTACT
      contact.send(:"#{contact.type_name.underscore.pluralize}").each do |p|
        p.status = Constants::CONTACT
      end
    end

    def after_save(contact, owner)
      create_default_relationships(contact, owner)
      contact.reload
      Sunspot.index contact.relationships.contact_by(owner)
      Sunspot.index contact.relationships.employees if company_contact?(contact, owner)
    end

    def create_default_relationships(contact, owner)
      # Identify the contact's owner
      contact.relationships.where(:association_type => Constants::BELONG, :contact_id => owner.id).first_or_create
    end
  end
end