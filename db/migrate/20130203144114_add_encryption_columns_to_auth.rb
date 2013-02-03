class AddEncryptionColumnsToAuth < ActiveRecord::Migration
  def up
    add_column :auths, :encrypted_secret, :string
    add_column :auths, :encrypted_secret_salt, :string
    add_column :auths, :encrypted_secret_iv, :string
    
    Auth.all.each do |auth|
      auth.secret = auth.read_attribute('secret')
      auth.save
    end
    
    remove_column :auths, :secret
  end
  
  def down
    add_column :auths, :secret, :string
    
    Auth.all.each do |auth|
      auth.send :write_attribute, 'secret', auth.secret
      auth.save
    end

    remove_column :auths, :encrypted_secret
    remove_column :auths, :encrypted_secret_salt
    remove_column :auths, :encrypted_secret_iv
  end
end
