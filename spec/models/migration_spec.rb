require 'spec_helper'

describe Migration do
  before do
    Desk.configure{ |c| c.use_max_requests = false }
  end

  context 'has to be valid and' do
    before do
      @migration = Migration.new
    end
    
    it 'validates the :to is present' do
      is_valid(@migration, :to, Auth.new)
    end
    it 'validates the :from is present' do
      is_valid(@migration, :from, Auth.new)
    end
  end
  
  context '#migrate' do
    before do
      @migration = FactoryGirl.create(:migration)
      @migration.from.token = ENV['ZENDESK_USERNAME']
      @migration.from.secret = ENV['ZENDESK_PASSWORD']
      @migration.save!
    end

    it 'exports valid json' do
      VCR.use_cassette 'migration/process' do
        tempfile = @migration.process_migration
        tempfile.rewind
        tempfile.read.should be_json
        
        tempfile.rewind
        
        output = File.open(Rails.root.join('log', 'export.json'), 'w+')
        output << tempfile.read
        output.close
        tempfile.close
      end
    end
  end
end
