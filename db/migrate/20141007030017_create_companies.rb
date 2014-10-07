class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string   "company_name"
      t.string   "phone_1"
      t.string   "phone_2"
      t.string   "phone_tag_1"
      t.string   "phone_tag_2"
      t.string	 "website"
      t.string   "address_line_1"
      t.string   "address_line_2"
      t.string   "city"
      t.string   "state"
      t.integer  "zipcode"
      t.timestamps
    end
  end
end
