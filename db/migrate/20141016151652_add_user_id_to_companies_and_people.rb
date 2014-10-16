class AddUserIdToCompaniesAndPeople < ActiveRecord::Migration
  def change
    add_column :companies, :user_id, :integer
    add_column :people, :user_id, :integer
  end
end
