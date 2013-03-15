require 'spec_helper'

describe Provider, broken: true do
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
        stub_request(:get, /.*devel\.desk\.com.*/).
           to_return(body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'))
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