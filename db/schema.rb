# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "location", primary_key: "location_id", force: :cascade do |t|
    t.string   "code",            limit: 45
    t.string   "name",            limit: 255, default: "",    null: false
    t.string   "description",     limit: 255
    t.string   "postal_code",     limit: 50
    t.string   "country",         limit: 50
    t.string   "latitude",        limit: 50
    t.string   "longitude",       limit: 50
    t.integer  "creator",         limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                  null: false
    t.string   "county_district", limit: 255
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by",       limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",     limit: 255
    t.integer  "parent_location", limit: 4
    t.integer  "changed_by",      limit: 4
    t.datetime "changed_at"
  end

  add_index "location", ["changed_by"], name: "location_changed_by", using: :btree
  add_index "location", ["creator"], name: "user_who_created_location", using: :btree
  add_index "location", ["name"], name: "name_of_location", using: :btree
  add_index "location", ["parent_location"], name: "parent_location", using: :btree
  add_index "location", ["voided"], name: "retired_status", using: :btree
  add_index "location", ["voided_by"], name: "user_who_retired_location", using: :btree

  create_table "location_tag", primary_key: "location_tag_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "locked",      limit: 1,   default: 0, null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "location_tag", ["location_tag_id"], name: "location_tag_map_id_UNIQUE", unique: true, using: :btree

  create_table "location_tag_map", id: false, force: :cascade do |t|
    t.integer "location_id",     limit: 4, null: false
    t.integer "location_tag_id", limit: 4, null: false
  end

  add_index "location_tag_map", ["location_id"], name: "fk_location_tag_map_1", using: :btree
  add_index "location_tag_map", ["location_tag_id"], name: "fk_location_tag_map_2_idx", using: :btree

  create_table "permission_role", force: :cascade do |t|
    t.integer "permission_id", limit: 4, null: false
    t.integer "role_id",       limit: 4, null: false
  end

  add_index "permission_role", ["permission_id"], name: "permission_role_permission_id_foreign", using: :btree
  add_index "permission_role", ["role_id"], name: "permission_role_role_id_foreign", using: :btree

  create_table "user_role", force: :cascade do |t|
    t.integer "user_id", limit: 4, null: false
    t.integer "role_id",       limit: 4, null: false
  end

  add_index "user_role", ["user_id"], name: "user_role_user_id_foreign", using: :btree
  add_index "user_role", ["role_id"], name: "user_role_role_id_foreign", using: :btree

  create_table "permission", primary_key: "permission_id", force: :cascade do |t|
    t.string   "name",         limit: 255, null: false
    t.string   "display_name", limit: 255, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "permission", ["name"], name: "permission_name_unique", unique: true, using: :btree

  create_table "role", primary_key: "role_id", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 200
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "client_type", primary_key: "client_type_id", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 200
    t.boolean  "voided",                      default: false, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "role", ["name"], name: "role_name_unique", unique: true, using: :btree

  create_table "user", primary_key: "user_id", force: :cascade do |t|
    t.string   "username",       limit: 50,              null: false
    t.string   "password",       limit: 100,             null: false
    t.string   "email",          limit: 100,             null: false
    t.string   "first_name",                    limit: 255
    t.string   "middle_name",                    limit: 255
    t.string   "last_name",                    limit: 255
    t.integer  "gender",         limit: 1,   default: 0, null: false
    t.string   "designation",    limit: 100
    t.string   "image",          limit: 100
    t.string   "remember_token", limit: 100
    t.datetime   "last_password_date"
    t.datetime "deleted_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "user", ["username"], name: "user_username_unique", unique: true, using: :btree

  create_table "client", primary_key: "client_id", force: :cascade do |t|
    t.string   "identifier"
    t.string   "first_name",                    limit: 255
    t.string   "middle_name",                    limit: 255
    t.string   "last_name",                    limit: 255
    t.string   "first_name_code",         limit: 255
    t.string   "last_name_code",          limit: 255
    t.integer  "client_type_id",  null: false
    t.integer  "gender",         limit: 1,   default: 0, null: false
    t.date     "birthdate"
    t.string   "occupation"
    t.string   "address"
    t.string   "phone_number"
    t.string   "email",          limit: 100,             null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "client_identifier_type", primary_key: "client_identifier_type_id", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 200
    t.boolean  "voided",                      default: false, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "client_identifier", primary_key: "client_identifier_id", force: :cascade do |t|
    t.string   "value",                       limit: 255,    null: false
    t.integer  "client_id",                   null: false
    t.integer  "client_identifier_type_id",   null: false
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.integer  "creator",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "concept", primary_key: "concept_id", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "concept_set", primary_key: "concept_set_id", force: :cascade do |t|
    t.integer  "concept_id"
    t.integer  "concept_set"
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "encounter_type", primary_key: "encounter_type_id", force: :cascade do |t|
    t.string   "name"
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "workflow", primary_key: "workflow_id", force: :cascade do |t|
    t.string   "name"
    t.string   "description",                    limit: 255
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "encounter", primary_key: "encounter_id", force: :cascade do |t|
    t.integer  "encounter_type_id"
    t.integer  "workflow_id"
    t.datetime "encounter_datetime",                    null: false
    t.integer  "client_id",                   null: false
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "obs", primary_key: "obs_id", force: :cascade do |t|
    t.integer  "concept_id",                  null: false
    t.integer  "workflow_id",                 null: false
    t.integer  "encounter_id",                null: false
    t.integer  "value_numeric"
    t.integer  "value_coded"
    t.integer  "client_id",                   null: false
    t.datetime "value_datetime"
    t.string   "value_text"
    t.datetime "obs_datetime",                null: false
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "workflow_encounter_type", primary_key: "workflow_encounter_type_id", force: :cascade do |t|
    t.integer  "workflow_id"
    t.integer  "encounter_type_id"
    t.integer  "sort_order"
    t.integer  "creator"
    t.boolean  "voided",                      default: false, null: false
    t.integer  "voided_by"
    t.string   "void_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_foreign_key "concept", "user", column: "voided_by", primary_key: "user_id", name: "fk_concept_1"
  add_foreign_key "concept", "user", column: "creator", primary_key: "user_id", name: "fk_concept_2"

  add_foreign_key "client_identifier", "client", column: "client_id", primary_key: "client_id", name: "fk_client_identifier_1"
  add_foreign_key "client_identifier", "client_identifier_type", column: "client_identifier_type_id", primary_key: "client_identifier_type_id", name: "fk_client_identifier_2"
  add_foreign_key "client_identifier", "user", column: "voided_by", primary_key: "user_id", name: "fk_client_identifier_3"
  add_foreign_key "client_identifier", "user", column: "creator", primary_key: "user_id", name: "fk_client_identifier_4"

  add_foreign_key "concept_set", "user", column: "voided_by", primary_key: "user_id", name: "fk_concept_set_1"
  add_foreign_key "concept_set", "user", column: "creator", primary_key: "user_id", name: "fk_concept_set_2"
  add_foreign_key "concept_set", "concept", column: "concept_set", primary_key: 'concept_id', name: "fk_concept_set_3"
  add_foreign_key "concept_set", "concept", column: "concept_id", primary_key: 'concept_id', name: "fk_concept_set_4"

  add_foreign_key "obs", "workflow", column: "workflow_id", primary_key: "workflow_id", name: "fk_obs_1"
  add_foreign_key "obs", "user", column: "creator", primary_key: "user_id", name: "fk_obs_2"
  add_foreign_key "obs", "user", column: "voided_by", primary_key: 'user_id', name: "fk_obs_3"
  add_foreign_key "obs", "concept", column: "concept_id", primary_key: 'concept_id', name: "fk_obs_4"
  add_foreign_key "obs", "encounter", column: "encounter_id", primary_key: 'encounter_id', name: "fk_obs_5"
  add_foreign_key "obs", "concept", column: "value_coded", primary_key: 'concept_id', name: "fk_obs_6"
  add_foreign_key "obs", "client", column: "client_id", primary_key: 'client_id', name: "fk_obs_7"

  add_foreign_key "encounter", "encounter_type", primary_key: "encounter_type_id", column: "encounter_type_id", name: "fk_encounter_1"
  add_foreign_key "encounter", "user", primary_key: "user_id", column: "creator", name: "fk_encounter_2"
  add_foreign_key "encounter", "user", primary_key: "user_id", column: "voided_by", name: "fk_encounter_3"
  add_foreign_key "encounter", "client", column: "client_id", primary_key: 'client_id', name: "fk_oencounter_4"

  add_foreign_key "workflow", "user", column: "voided_by", primary_key: "user_id", name: "fk_workflow_1"
  add_foreign_key "workflow", "user", column: "creator", primary_key: "user_id", name: "fk_workflow_2"

  add_foreign_key "encounter_type", "user", column: "voided_by", primary_key: "user_id", name: "fk_encounter_type_1"
  add_foreign_key "encounter_type", "user", column: "creator", primary_key: "user_id", name: "fk_encounter_type_2"

  add_foreign_key "client", "client_type", primary_key: "client_type_id", name: "fk_client_1"

  add_foreign_key "workflow_encounter_type", "user", column: "voided_by", primary_key: "user_id", name: "fk_workflow_encounter_type_1"
  add_foreign_key "workflow_encounter_type", "user", column: "creator", primary_key: "user_id", name: "fk_workflow_encounter_type_2"
  add_foreign_key "workflow_encounter_type", "workflow", column: 'workflow_id', primary_key: "workflow_id", name: "fk_workflow_encounter_type_3"
  add_foreign_key "workflow_encounter_type", "encounter_type", column: "encounter_type_id", primary_key: "encounter_type_id", name: "fk_workflow_encounter_type_4"

  add_foreign_key "location_tag_map", "location", primary_key: "location_id", name: "fk_location_tag_map_1"
  add_foreign_key "location_tag_map", "location_tag", primary_key: "location_tag_id", name: "fk_location_tag_map_2"

  add_foreign_key "permission_role", "role", primary_key: "role_id", name: "fk_permission_role_2"
  add_foreign_key "permission_role", "permission", primary_key: "permission_id", name: "fk_permission_role_1"

  add_foreign_key "user_role", "role", primary_key: "role_id", name: "fk_user_role_2"
  add_foreign_key "user_role", "user", primary_key: "user_id", name: "fk_user_role_1"
end
