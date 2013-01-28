class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    
    change_table :users do |t|
      t.belongs_to :role
    end
  end
end
