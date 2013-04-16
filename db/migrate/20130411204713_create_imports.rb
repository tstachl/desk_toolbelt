class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :method
      t.string :format
      t.text :description
      t.boolean :is_imported
      t.boolean :is_importing
      t.references :auth
      t.attachment :file
      t.attachment :logfile
      t.string :type

      t.timestamps
    end
    add_index :imports, :auth_id
  end
end
