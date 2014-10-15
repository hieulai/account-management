class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
        t.string   "password"
        t.boolean  "active"
    end
  end
end
