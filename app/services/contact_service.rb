class ContactService

  class << self
    include ActionView::Helpers::NumberHelper

    def create(new_contact, owner)
      before_save(new_contact, owner)
      check_valid(new_contact, owner)
      check_for_relationships(new_contact, owner)
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
      check_for_relationships(contact, owner)
      check_for_duplication(contact, owner)

      if contact.errors.empty? && contact.skip_existing_checking.blank?
        UserService.check_for_existing(contact)
      end

      if contact.errors.empty? && contact.save
        after_save(contact, owner)
      end
      contact
    end

    def merge(contact, updated_contact, owner)
      attributes = {}
      attributes[:relationships_attributes] = []
      merged_relationships = contact.relationships
      merged_relationships = merged_relationships.contact_by(owner).reject { |r| r.association_type == Constants::BELONG } unless contact.new_record?
      merged_relationships = merged_relationships.reject { |r| updated_contact.relationships.contact_by(r.contact).types(r.association_type).any? }
      merged_relationships.each do |r|
        attributes[:relationships_attributes] << {association_type: r.association_type, contact_id: r.contact_id}
      end

      updated_time = contact.new_record? ? Time.now : contact.profile.updated_at
      if !updated_contact.is_real? && (updated_time > updated_contact.profile.updated_at)
        profile_attributes = contact.profile.attributes.delete_if { |k, v| v.blank? || %w(deleted_at created_at updated_at user_id).include?(k) }
        profile_attributes['id'] = updated_contact.profile.id
        attributes[:"#{updated_contact.type_name.underscore.pluralize}_attributes"] = profile_attributes
      end

      if updated_contact.update_attributes(attributes)
        contact.destroy unless contact.new_record?
      end
      updated_contact
    end

    def import(file, owner)
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
        contact = process_import(row, type, owner)
        if contact.new_record?
          errors << "Importing Error at line #{i}: #{contact.errors.full_messages}"
        else
          after_save(contact, owner)
          objects << contact
        end
      end
      {errors: errors, objects: objects}
    end

    def export(contacts, type, owner, options = {})
      CSV.generate(options) do |csv|
        if type == Constants::COMPANY
          csv << Constants::COMPANY_CONTACT_HEADERS.map { |h| h.tr("_", " ").capitalize }
          contacts.each do |contact|
            csv << [contact.profile.company_name, contact.profile.address_line_1, contact.profile.address_line_2, number_to_phone(contact.profile.phone_1, :area_code => true), contact.profile.phone_tag_1, note_for(contact, owner).try(:content), relationship_names_for(contact, owner)]
          end
        else
          csv << Constants::PERSON_CONTACT_HEADERS.map { |h| h.tr("_", " ").capitalize }
          contacts.each do |contact|
            csv << [contact.profile.first_name, contact.profile.last_name, contact.email, contact.profile.address_line_1, contact.profile.address_line_2, number_to_phone(contact.profile.phone_1, :area_code => true), contact.profile.phone_tag_1, employment_status_for(contact, owner), note_for(contact, owner).try(:content), relationship_names_for(contact, owner)]
          end
        end
      end
    end

    def destroy(contact, owner)
      contact.relationships.contact_by(owner).destroy_all
      owner.relationships.contact_by(contact).destroy_all
      if contact.is_a? CompanyUser
        contact.employees.each do |c|
          c.relationships.contact_by(contact).destroy_all
          contact.relationships.contact_by(c).destroy_all
          destroy(c, owner)
        end
      end
      contact.destroy unless contact.is_real? || contact.relationships.any?
      contact
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
      array << Constants::EMPLOYEE if contact.is_a?(PersonUser) && owner.is_a?(CompanyUser)
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

    private
    def employment_status_for(contact, owner)
      contact.employers.first.try(:display_name) || Constants::SELF_EMPLOYED_STATUS
    end

    def relationship_names_for(contact, owner)
       names = []
       contact.relationships.contact_by(owner).reject { |r| r.is_a_belong? }.each do |r|
         names << r.association_type
       end
      names.join(", ")
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::Csv.new(file.path,nil)
        when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
        else nil
      end
    end

    def process_import(row, type, owner)
      contact_params = initiate_contact_params(row, type, owner)
      contact = User.new(contact_params)
      check_for_relationships(contact, owner)
      return contact if contact.errors.any?

      duplications = search_for_duplications(contact, owner)
      return merge(contact, duplications.first, owner) if duplications.any?

      existings = UserService.search_for_existings(contact)
      return merge(contact, existings.first, owner) if existings.any?

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
        contact_params.merge!(type: "PersonUser", email: row[Constants::EMAIL], people_attributes: [{first_name: row[Constants::FIRST_NAME], last_name: row[Constants::LAST_NAME], address_line_1: row[Constants::ADDRESS_LINE_1], address_line_2: row[Constants::ADDRESS_LINE_2], phone_1: row[Constants::PHONE], phone_tag_1: row[Constants::PHONE_TAG]}], notes_attributes: [{content: row[Constants::NOTES]}])
        if row[Constants::EMPLOYMENT_STATUS].present? && row[Constants::EMPLOYMENT_STATUS] != Constants::SELF_EMPLOYED_STATUS
          duplications = search_for_duplications(CompanyUser.new({companies_attributes: [{company_name: row[Constants::EMPLOYMENT_STATUS]}]}), owner)
          if duplications.any?
            contact_params[:relationships_attributes] = [{association_type: Constants::EMPLOYEE, contact_id: duplications.first.id}]
          end
        end
      else
        contact_params.merge!(type: "CompanyUser", companies_attributes: [{company_name: row[Constants::COMPANY_NAME], address_line_1: row[Constants::ADDRESS_LINE_1], address_line_2: row[Constants::ADDRESS_LINE_2], phone_1: row[Constants::PHONE], phone_tag_1: row[Constants::PHONE_TAG]}], notes_attributes: [{content: row[Constants::NOTES]}])
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
    end

    def create_default_relationships(contact, owner)
      # Identify the contact's owner
      contact.relationships.where(:association_type => Constants::BELONG, :contact_id => owner.id).first_or_create
    end
  end
end