class AddIndexOnUserIdAndContactIdToAssociations < ActiveRecord::Migration
  def change
    add_index :associations, :user_id
    add_index :associations, :contact_id
  end
end
