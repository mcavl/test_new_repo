class CreatePractitioners < ActiveRecord::Migration[7.1]
  def change
    create_table :practitioners do |t|
      t.string :first_name
      t.string :last_name
      t.string :specialty

      t.timestamps
    end
  end
end
