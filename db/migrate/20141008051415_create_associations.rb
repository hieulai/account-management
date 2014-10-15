class CreateAssociations < ActiveRecord::Migration
  def change
    create_table :associations do |t|
      t.integer :user_id
      t.integer :contact_id
      t.string  :association_type
      t.timestamps
    end
  end
end
