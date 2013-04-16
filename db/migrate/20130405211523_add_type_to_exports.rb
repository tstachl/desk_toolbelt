class AddTypeToExports < ActiveRecord::Migration
  def change
    add_column :exports, :type, :string, default: 'Export'
    add_column :exports, :source, :string
    add_column :exports, :target, :string
  end
end
