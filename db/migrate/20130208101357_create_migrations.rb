class CreateMigrations < ActiveRecord::Migration
  def change
    create_table :migrations do |t|
      t.belongs_to :to
      t.belongs_to :from
      t.boolean :customers
      t.boolean :cases
      t.boolean :interactions
      t.boolean :topics
      t.boolean :articles

      t.timestamps
    end
    add_index :migrations, :to_id
    add_index :migrations, :from_id
  end
end
