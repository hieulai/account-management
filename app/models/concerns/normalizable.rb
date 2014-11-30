module Normalizable
  extend ActiveSupport::Concern

  module ClassMethods
    def trimmed_fields *field_list
      before_save do |model|
        field_list.each do |n|
          model[n] = model[n].strip if model[n].respond_to?('strip')
        end
      end
    end

    def phony_fields *field_list
      validate do |model|
        field_list.each do |n|
          errors.add(n, "is not a valid phone number") if model[n].present? && !GlobalPhone.validate(model[n])
        end
      end

      before_save do |model|
        field_list.each do |n|
          model[n] = GlobalPhone.parse(model[n]).national_string if model[n].present?
        end
      end
    end

    def url_fields *field_list
      before_save do |model|
        field_list.each do |n|
          model[n] = model[n].sub(/^https?\:\/\//, '').sub(/^www./, '') if model[n].present?
        end
      end
    end

    def int_fields *field_list
      before_save do |model|
        field_list.each do |n|
          model[n] = model[n].to_i.to_s if !!Float(model[n]) rescue false
        end
      end
    end
  end
end