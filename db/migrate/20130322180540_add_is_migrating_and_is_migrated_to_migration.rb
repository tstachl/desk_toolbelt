class AddIsMigratingAndIsMigratedToMigration < ActiveRecord::Migration
  def change
    add_column :migrations, :is_migrating, :boolean
    add_column :migrations, :is_migrated, :boolean
  end
end