class RenameAssociationsToRelationships < ActiveRecord::Migration
  def change
    rename_table :associations, :relationships
  end
end
