class CorrectZipcodeOnPeople < ActiveRecord::Migration
  def change
      change_table :people do |t|
          t.rename :zipdode, :zipcode
      end
  end
end
