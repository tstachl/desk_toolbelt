FactoryGirl.define do
  sequence :filter do |n|
    { 
      'name' => (n % 2 == 1) ? '' : Faker::Name.name, 
      'first_name' => '', 
      'last_name' => '', 
      'email' => (n % 2 == 1) ? '' : Faker::Internet.email, 
      'phone' => '', 
      'company' => '',
      'twitter' => '',
      'labels' => '',
      'case_id' => '',
      'subject' => '',
      'description' => '',
      'priority' => '',
      'assigned_group' => '',
      'assigned_user' => '',
      'channels' => '',
      'notes' => '',
      'attachments' => '',
      'created' => '',
      'updated' => '',
      'since_created_at' => '',
      'max_created_at' => '',
      'since_updated_at' => '',
      'max_updated_at' => '',
      'since_id' => '',
      'max_id' => ''
    }
  end
  
  factory :export do
    filter
    method 'cases'
    description 'RSpec test'
    format 'json'
    total 11
    pages 1
    auth
    
    factory :preview_export do
      total nil
      pages nil
    end
    
    factory :exported_export do
      is_exported true
      is_exporting false
      file File.new(Rails.root + 'spec/fixtures/export/cases.json')
    end
    
    factory :exporting_export do
      is_exporting true
    end
  end
end