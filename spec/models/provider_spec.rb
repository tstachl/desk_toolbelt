require 'spec_helper'

describe Provider do
  describe Provider::Desk do
    before do
      @auth = FactoryGirl.create :auth
    end
    
    it 'returns markup for all suported types' do
      Provider::SUPPORTED_TYPES.each { |item| 
        @auth.provider.markup[item].should be_kind_of Hash
      }
    end
    
    it 'returns create markup for all supported types' do
      Provider::SUPPORTED_TYPES.each { |item| 
        @auth.provider.markup_create[item].should be_kind_of Hash
      }
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
  
  describe Provider::Zendesk do
    before do
      @auth = FactoryGirl.create :auth_zendesk
    end
    
    it 'returns markup for all supported types' do
      Provider::SUPPORTED_TYPES.each { |item| 
        @auth.provider.markup[item].should be_kind_of Hash
      }
    end
  end
end