FactoryGirl.define do
  factory :import do
    file File.new(Rails.root + 'spec/fixtures/import/import.json')
    description 'RSpec test'
    auth
    
    factory :migration_import do
      migration
      
      factory :imported_migration_import do
        is_imported true
        is_importing false
      end
      
      factory :importing_migration_import do
        is_importing true
      end
      
      factory :error_migration_import do
        is_error true
        messages 'The import was cancelled.'
      end
    end
    
    factory :imported_import do
      is_imported true
      is_importing false
    end
    
    factory :importing_import do
      is_importing true
    end
    
    factory :error_import do
      is_error true
      messages 'The import was cancelled.'
    end
  end
end