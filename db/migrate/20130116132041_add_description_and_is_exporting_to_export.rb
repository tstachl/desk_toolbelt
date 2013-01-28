class AddDescriptionAndIsExportingToExport < ActiveRecord::Migration
  def change
    add_column :exports, :description, :text
    add_column :exports, :is_exporting, :boolean
  end
end
