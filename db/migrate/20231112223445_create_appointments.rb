class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :appointment_type, null: false
      t.references :practitioner, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :clinic, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :appointments, %i[clinic_id patient_id]
    add_index :appointments, %i[clinic_id practitioner_id]
  end
end
