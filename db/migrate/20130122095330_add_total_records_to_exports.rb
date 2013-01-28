class AddTotalRecordsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :total, :integer
  end
end
