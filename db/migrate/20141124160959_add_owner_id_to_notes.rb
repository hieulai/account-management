class AddOwnerIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :owner_id, :integer
    add_index :notes, :owner_id
  end
end
