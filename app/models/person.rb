class Person < ActiveRecord::Base
  belongs_to :person_user, foreign_key: :user_id
end
