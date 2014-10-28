class RemoveEmailFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :email
  end
end
