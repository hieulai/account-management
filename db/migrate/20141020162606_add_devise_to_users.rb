class AddDeviseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :encrypted_password, :string, :null => false, :default => ""

    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
  end
end
