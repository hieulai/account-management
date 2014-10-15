class AddColumnsToCompanyAndPerson < ActiveRecord::Migration
  def change
   	change_table :people do |t|
  	  t.string :first_name
  	  t.string :last_name
  	  t.string :email
  	  t.string :phone_1
  	  t.string :phone_2
  	  t.string :phone_tag_1
  	  t.string :phone_tag_2
  	  t.string :address_line_1
  	  t.string :address_line_2
  	  t.string :city
  	  t.string :state
  	  t.string :zipdode
  	  t.string :website
  	end
  end
end
