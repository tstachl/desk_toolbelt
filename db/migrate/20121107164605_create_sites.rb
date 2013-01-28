class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :sites, :name
  end
end
