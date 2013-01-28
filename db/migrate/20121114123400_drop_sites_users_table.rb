class DropSitesUsersTable < ActiveRecord::Migration
  def change
    drop_table :sites_users
  end
end
