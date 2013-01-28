class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :method
      t.text :filter
      t.references :auth
      t.boolean :is_exported

      t.timestamps
    end
    add_index :exports, :auth_id
  end
end
