require 'spec_helper'

describe Export do
  before do
    Desk.configure{ |c| c.use_max_requests = false }
  end
  
  context 'has to be valid and' do
    before do
      @export = Export.new
    end
  
    it 'validates the filter is present' do
      is_valid(@export, :filter, Faker::Lorem.word)
    end
    it 'validates the method is present' do
      is_valid(@export, :method, Faker::Lorem.word)
    end
    it 'validates the format is present' do
      is_valid(@export, :format, 'xml')
    end
    it 'validates the auth is present' do
      is_valid(@export, :auth, Auth.new)
    end
  end
  
  context '#preview' do
    before do
      @export = FactoryGirl.create :preview_export
    end
    
    it 'fetches and return 10 cases' do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=10&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
      @export.preview['count'].should == 10 
    end
  end

  context '#header' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=10&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
      @export = FactoryGirl.create :exporting_export
      @item = @export.preview['results'].first
    end

    it 'returns the case file header for json' do
      @export.format = 'json'
      @export.header(@item).should == '{"cases":['
    end

    it 'returns the case file header for xml' do
      @export.format = 'xml'
      @export.header(@item).should == '<cases>'
    end

    it 'returns the case file header for csv' do
      @export.format = 'csv'
      @export.header(@item).should == "#{@item['case'].keys.to_csv}"
    end
  end

  context '#row' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=10&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
      @export = FactoryGirl.create :exporting_export
      @item = @export.preview['results'].first
    end

    it 'returns the case file header for json' do
      @export.format = 'json'
      @export.row(@item).should == @item['case'].to_json.concat(',')
    end

    it 'returns the case file header for xml' do
      @export.format = 'xml'
      @export.row(@item).should == @item['case'].to_xml(root: 'case', skip_instruct: true)
    end

    it 'returns the case file header for csv' do
      @export.format = 'csv'
      @export.row(@item).should == @item['case'].values.map{ |v| Export.tabular_value(v) }.to_csv
    end
  end

  context '#footer' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=10&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
      @export = FactoryGirl.create :exporting_export
    end

    it 'returns the case file header for json' do
      @export.format = 'json'
      @export.footer.should == ']}'
    end

    it 'returns the case file header for xml' do
      @export.format = 'xml'
      @export.footer.should == '</cases>'
    end
  end
  
  context '#export' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=100&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases_export.json'), headers: {content_type: "application/json; charset=utf-8"})
      @export = FactoryGirl.create :preview_export
    end

    it 'exports valid json' do
      @export.format = 'json'
      tempfile = @export.process_export
      tempfile.rewind
      tempfile.read.should be_json
    end

    it 'exports valid xml' do
      @export.format = 'xml'
      tempfile = @export.process_export
      tempfile.rewind
      tempfile.read.should be_xml
    end

    it 'exports valid csv' do
      @export.format = 'csv'
      tempfile = @export.process_export
      tempfile.rewind
      tempfile.read.should be_csv
    end
  end
  
  context '#fetch_export' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=100&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=2&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases_export.json'), headers: {content_type: "application/json; charset=utf-8"})
      Export.any_instance.stub(:save_attached_files).and_return(true)
      @export = FactoryGirl.create :preview_export
    end
    
    context 'testing max requests' do
      before do
        Desk.use_max_requests = true
        Desk.max_requests = 60
        Desk.counter = 0
      end
      
      after do
        Desk.use_max_requests = false
        Desk.counter = 0
      end
      
      it 'sleeps for a minute after 60' do
        70.times {
          @export.instance_eval{ fetch_export(Export::DEFAULT_MAX_COUNT, 2) } 
        }
        Desk.counter.should == 10
      end
    end
  end
  
  context '#run' do
    before do
      stub_request(:get, "https://devel.desk.com/api/v1/cases.json?assigned_group=&assigned_user=&attachments=&case_id=&channels=&company=&count=100&created=&description=&email=&first_name=&labels=&last_name=&max_created_at=&max_id=&max_updated_at=&name=&notes=&page=1&phone=&priority=&since_created_at=&since_id=&since_updated_at=&subject=&twitter=&updated=").
         to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases_export.json'), headers: {content_type: "application/json; charset=utf-8"})
      Export.any_instance.stub(:save_attached_files).and_return(true)
      @export = FactoryGirl.create :preview_export
    end
    
    it 'sets :is_exporting to false' do
      Export.run @export.id
      Export.find(@export.id).is_exporting.should be_false
    end

    it 'sets :is_exported to true' do
      Export.run @export.id
      Export.find(@export.id).is_exported.should be_true
    end

    it 'adds a file' do
      Export.run @export.id
      Export.find(@export.id).file.should_not be_nil
    end
  end
  
  context "#tabular_value" do
    context "if in desk context" do
      before do
        @array = [
          {'email' => {'email' => 'tom@desk.com', 'id' => '1'}},
          {'twitter' => {'login' => 'thomasstachl', 'id' => '2'}},
          {'name' => 'Test Group', 'id' => '3'}
        ]
        @hash = {'name' => 'Test Group', 'id' => '3'}
        @date = '2013-01-21T10:44:30-08:00'
        @value = 'anything else'
      end
      
      it "should handle an array" do
        Export.tabular_value(@array).should eq '1;2;3'
        Export.tabular_value(@array, false).should eq 'tom@desk.com;thomasstachl;Test Group'
      end
      
      it "should handle a hash" do
        Export.tabular_value(@hash).should eq '3'
        Export.tabular_value(@hash, false).should eq 'Test Group'
      end
      
      it "should handle a date" do
        Export.tabular_value(@date).should eq @date
        Export.tabular_value(@date, nil, :short).should eq DateTime.parse(@date).to_s(:short)
      end
      
      it "should handle any other value" do
        Export.tabular_value(@value).should eq @value
      end
    end
  end
end
