class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.belongs_to :user
      t.belongs_to :site

      t.timestamps
    end
    
    add_index :auths, :provider
    add_index :auths, :uid
    add_index :auths, :user_id
    add_index :auths, :site_id
  end
end
