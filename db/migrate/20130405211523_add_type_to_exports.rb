class AddTypeToExports < ActiveRecord::Migration
  def change
    add_column :exports, :type, :string, default: 'Export'
  end
end
