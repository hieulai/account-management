class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.text :content
      t.time :deleted_at
      t.timestamps
    end

    add_index :notes, :user_id
  end
end
