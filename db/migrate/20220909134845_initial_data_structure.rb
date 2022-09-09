class InitialDataStructure < ActiveRecord::Migration[6.1]
  def change
    create_table "decidim_ideas", force: :cascade do |t|
      t.jsonb "title", null: false
      t.jsonb "description", null: false
      t.integer "decidim_organization_id"
      t.bigint "decidim_author_id", null: false
      t.datetime "published_at"
      t.integer "state", default: 0, null: false
      t.jsonb "answer"
      t.datetime "answered_at"
      t.string "answer_url"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "decidim_user_group_id"
      t.string "hashtag"
      t.integer "scoped_type_id"
      t.string "decidim_author_type", null: false
      t.string "reference"
      t.integer "comments_count", default: 0, null: false
      t.integer "follows_count", default: 0, null: false
      t.index "md5((description)::text)", name: "decidim_ideas_description_search"
      t.index ["answered_at"], name: "index_decidim_ideas_on_answered_at"
      t.index ["decidim_author_id", "decidim_author_type"], name: "index_decidim_ideas_on_decidim_author"
      t.index ["decidim_organization_id"], name: "index_decidim_ideas_on_decidim_organization_id"
      t.index ["decidim_user_group_id"], name: "index_decidim_ideas_on_decidim_user_group_id"
      t.index ["published_at"], name: "index_decidim_ideas_on_published_at"
      t.index ["scoped_type_id"], name: "index_decidim_ideas_on_scoped_type_id"
      t.index ["title"], name: "decidim_ideas_title_search"
    end
    
    create_table "decidim_ideas_settings", force: :cascade do |t|
      t.string "ideas_order", default: "random"
      t.bigint "decidim_organization_id"
      t.index ["decidim_organization_id"], name: "index_decidim_ideas_settings_on_decidim_organization_id"
    end
    
    create_table "decidim_ideas_type_scopes", force: :cascade do |t|
      t.bigint "decidim_ideas_types_id"
      t.bigint "decidim_scopes_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["decidim_ideas_types_id"], name: "idx_scoped_idea_type_type"
      t.index ["decidim_scopes_id"], name: "idx_scoped_idea_type_scope"
    end
    
    create_table "decidim_ideas_types", force: :cascade do |t|
      t.jsonb "title", null: false
      t.jsonb "description", null: false
      t.integer "decidim_organization_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "banner_image"
      t.boolean "child_scope_threshold_enabled", default: false, null: false
      t.boolean "only_global_scope_enabled", default: false, null: false
      t.boolean "attachments_enabled", default: false, null: false
      t.boolean "comments_enabled", default: true, null: false
      t.index ["decidim_organization_id"], name: "index_decidim_idea_types_on_decidim_organization_id"
    end
  end
end
