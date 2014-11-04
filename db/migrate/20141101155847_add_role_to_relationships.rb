class AddRoleToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :role, :string
  end
end
