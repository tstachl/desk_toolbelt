require 'spec_helper'

describe Export do
  pending "add some examples to (or delete) #{__FILE__}"
  
  context "has a tabular_value method" do
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
