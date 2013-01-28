class AddFormat < ActiveRecord::Migration
  def change
    add_column :exports, :format, :string
  end
end
