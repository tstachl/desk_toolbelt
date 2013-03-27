class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.references :auth
      t.references :migration
      t.boolean :is_importing
      t.boolean :is_imported
      t.boolean :is_error
      t.text :messages
      t.text :description
      t.attachment :file

      t.timestamps
    end
    add_index :imports, :auth_id
  end
end
