require 'spec_helper'

describe Import do
  context 'has to be valid and' do
    it 'validates the auth is present' do
      is_valid(Import.new, :auth, Auth.new)
    end
    it 'validates the file is present' do
      is_valid(Import.new, :file, Tempfile.new('testing'))
    end
  end
  
  context '#import' do
    before do
      Import.any_instance.stub(:save_attached_files).and_return(true)
      @import = FactoryGirl.create(:import)
      @import.auth.token = ENV['DESK_TOKEN']
      @import.auth.secret = ENV['DESK_SECRET']
    end
    
    it 'imports the file into desk' do
      # https://s3.amazonaws.com/desk-customers/tempfiles/exporter/test/import/import.json?1363986380
      stub_request(:get, /.*s3\.amazonaws\.com.*/).
         to_return(body: File.new(Rails.root + 'spec/fixtures/import/import.json'))
      
      VCR.use_cassette 'import/import' do
        @import.import
      end
    end
  end
end
