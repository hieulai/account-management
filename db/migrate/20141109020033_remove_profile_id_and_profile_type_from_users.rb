class RemoveProfileIdAndProfileTypeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :profile_id
    remove_column :users, :profile_type
  end
end
