require 'spec_helper'

describe Provider do
  describe Provider::Desk do
    before do
      @auth = FactoryGirl.create :auth
    end
    
    context '#client' do
      it 'creates a client' do
        @auth.provider.client.should_not be_nil
      end
      
      it 'creates a client with auth properties' do
        @auth.provider.client.subdomain.should == @auth.site.name
        @auth.provider.client.oauth_token.should == @auth.token
        @auth.provider.client.oauth_token_secret.should == @auth.secret
      end
    end
    
    context '#cases' do
      it 'fetches cases' do
        stub_request(:get, "https://devel.desk.com/api/v1/cases.json?count=10&page=1").
           to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
        @auth.provider.cases(count: 10, page: 1)["count"].should == 10
      end
    end
  end
end