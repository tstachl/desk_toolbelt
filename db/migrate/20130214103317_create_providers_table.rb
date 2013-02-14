class CreateProvidersTable < ActiveRecord::Migration
  def up
    create_table :providers do |t|
      t.string :type
      t.string :name
    end
    add_index :providers, :type, unique: true
    add_index :providers, :name, unique: true

    Provider.create type: 'Provider::Desk', name: 'desk'
    Provider.create type: 'Provider::Zendesk', name: 'zendesk'

    add_column :auths, :provider_id, :integer

    Auth.all.each do |auth|
      auth.send :write_attribute, 'provider_id', Provider.find_by_provider(auth.read_attribute('provider')).id
      auth.save
    end

    remove_column :auths, :provider
  end

  def down
    add_column :auths, :provider, :string
    
    Auth.all.each do |auth|
      auth.send :write_attribute, 'provider', auth.provider.type.underscore.split('/').last
      auth.save
    end
    
    remove_column :auths, :provider_id
    drop_table :providers
  end
end
