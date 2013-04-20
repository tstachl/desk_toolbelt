class AddMigrationFieldsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :articles, :boolean
    add_column :exports, :cases, :boolean
    add_column :exports, :interactions, :boolean
    add_column :exports, :customers, :boolean
    add_column :exports, :topics, :boolean
    add_column :exports, :from_id, :integer
    
    add_index :exports, :from_id
  end
end
