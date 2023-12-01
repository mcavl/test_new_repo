# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_11_12_223445) do
  create_table "appointments", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "appointment_type", null: false
    t.integer "practitioner_id", null: false
    t.integer "patient_id", null: false
    t.integer "clinic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinic_id", "patient_id"], name: "index_appointments_on_clinic_id_and_patient_id"
    t.index ["clinic_id", "practitioner_id"], name: "index_appointments_on_clinic_id_and_practitioner_id"
    t.index ["clinic_id"], name: "index_appointments_on_clinic_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["practitioner_id"], name: "index_appointments_on_practitioner_id"
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name"
    t.string "open_time"
    t.string "close_time"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "clinic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinic_id"], name: "index_patients_on_clinic_id"
  end

  create_table "practitioners", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "specialty"
    t.integer "clinic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clinic_id"], name: "index_practitioners_on_clinic_id"
  end

  add_foreign_key "appointments", "clinics"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "practitioners"
  add_foreign_key "patients", "clinics"
  add_foreign_key "practitioners", "clinics"
end
