class CorrectZipcodeonCompanies < ActiveRecord::Migration
  def change
      change_table :companies do |t|
          t.rename :zipdode, :zipcode
      end
  end
end
