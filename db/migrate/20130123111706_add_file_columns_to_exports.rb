class AddFileColumnsToExports < ActiveRecord::Migration
  def self.up
    add_attachment :exports, :file
  end

  def self.down
    remove_attachment :exports, :file
  end
end
