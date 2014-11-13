# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  active                 :boolean
#  profile_id             :integer
#  profile_type           :string(255)
#  type                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)
#  password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  deleted_at             :time
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    factory :person_user, class: PersonUser do
      email { generate(:email) }
      after(:build) do |object, evaluator|
        object.people << FactoryGirl.build(:person)
      end
      factory :real_person_user do
        password { generate(:string) }
      end

      factory :contact_person_user do
        password ""
      end

      factory :company_contact_person_user do
        after(:build) do |object, evaluator|
          existing = FactoryGirl.create :real_company_user
          object.relationships << FactoryGirl.build(:relationship, contact: existing, association_type: Constants::EMPLOYEE)
        end
      end
    end

    factory :company_user, class: CompanyUser do
      factory :real_company_user do
        after(:build) do |object, evaluator|
          object.companies << FactoryGirl.build(:company)
          object.relationships << FactoryGirl.build(:founder_relationship)
        end
      end

    end

  end
end
