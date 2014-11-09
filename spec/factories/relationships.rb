# == Schema Information
#
# Table name: relationships
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  contact_id       :integer
#  association_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  reflex           :boolean
#  role             :string(255)
#  deleted_at       :time
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :relationship do
    user
    contact :factory => :user
    association_type { Constants::ASSOCIATION_TYPES.sample }

    factory :founder_relationship do
      contact :factory => :real_person_user
      association_type Constants::EMPLOYER
      role Constants::OWNER
    end

    factory :belong_relationship do
      contact :factory => :real_person_user
      association_type Constants::BELONG
    end

    factory :client_relationship do
      contact :factory => :real_company_user
      association_type Constants::CLIENT
    end
  end
end
