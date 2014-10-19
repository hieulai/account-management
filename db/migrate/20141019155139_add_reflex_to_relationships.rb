class AddReflexToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :reflex, :boolean
  end
end
