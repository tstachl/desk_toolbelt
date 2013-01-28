class AddPagesColumnToExports < ActiveRecord::Migration
  def change
    add_column :exports, :pages, :integer
  end
end
