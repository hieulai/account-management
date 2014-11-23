# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  first_name     :string(255)
#  last_name      :string(255)
#  phone_1        :string(255)
#  phone_2        :string(255)
#  phone_tag_1    :string(255)
#  phone_tag_2    :string(255)
#  address_line_1 :string(255)
#  address_line_2 :string(255)
#  city           :string(255)
#  state          :string(255)
#  zipcode        :string(255)
#  website        :string(255)
#  user_id        :integer
#  deleted_at     :time
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    first_name { generate(:string) }
    last_name { generate(:string) }

    phone_1 { generate(:phone) }
    phone_tag_1 { Constants::PRIMARY_PHONE_TAGS.sample }
    phone_2 { generate(:phone) }
    phone_tag_2 { Constants::SECONDARY_PHONE_TAGS.sample }

    address_line_1 { generate(:string) }
    address_line_2 { generate(:string) }

    city { generate(:string) }
    state { generate(:string) }
    zipcode { generate(:number) }
    website { generate(:website) }

    factory :contact_person do
      last_name nil
    end
  end
end
