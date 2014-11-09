class AddDeletedAtToModels < ActiveRecord::Migration
  def change
    add_column :companies, :deleted_at, :time
    add_column :people, :deleted_at, :time
    add_column :relationships, :deleted_at, :time
    add_column :users, :deleted_at, :time
  end
end
