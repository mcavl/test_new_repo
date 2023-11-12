class CreateClinics < ActiveRecord::Migration[7.1]
  def change
    create_table :clinics do |t|
      t.string :name
      t.string :open_time
      t.string :close_time
      t.string :timezone

      t.timestamps
    end
  end
end
