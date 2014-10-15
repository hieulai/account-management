class RemoveItemsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password, :string
    remove_column :users, :type, :string
  end
end
