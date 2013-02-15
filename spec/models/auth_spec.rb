require 'spec_helper'

describe Auth do
  before(:each) do
    FactoryGirl.create :provider
    FactoryGirl.create :provider_zendesk
  end
  
  context 'has to be valid and' do
    before do
      @auth = Auth.new
    end
    
    # we can't validate the provider because it's overridden
    it 'validates the provider is present', broken: true do
      is_valid(@auth, :provider, Provider.new)
    end
    it 'validates the uid is present' do
      is_valid(@auth, :uid, Faker::Lorem.characters)
    end
    it 'validates the user is present' do
      is_valid(@auth, :user, User.new)
    end
    it 'validates the token is present' do
      is_valid(@auth, :token, Faker::Lorem.characters)
    end
  end
  
  context 'can handle additional authorizations' do
    before do
      @desk = OmniAuth.config.mock_auth[:desk]
      @user = User.create({
        :name => Faker::Name.name,
        :email => @desk.info.email,
        :role => Role.create(:name => 'siteadmin_billing')
      })
    end
  end
  
  context 'is used in the login/signup process' do
    before do
      @hash = OmniAuth.config.mock_auth[:desk]
    end
    
    it 'can handle omniauth and returns an auth record' do
      auth = Auth.from_omniauth @hash
      auth.user.kind_of?(User).should be_true
      auth.site.kind_of?(Site).should be_true
      auth.kind_of?(Auth).should be_true
    end
    
    it 'can initialize by omniauth' do
      auth = Auth.find_or_initialize_by_omniauth @hash
      auth.should be_new_record
      auth.provider.name.should eq(@hash.provider)
      auth.uid.should eq(@hash.uid)
      auth.token.should eq(@hash.credentials.token)
      auth.secret.should eq(@hash.credentials.secret)      
    end
    
    context 'if it exists' do
      before do
        @hash = OmniAuth.config.mock_auth[:desk]
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        @auth.token = Faker::Lorem.characters
        @auth.secret = Faker::Lorem.characters
        @auth.save!
      end
      
      it 'updates the auth record' do
        @auth.token.should_not eq(@hash.credentials.token)
        @auth.secret.should_not eq(@hash.credentials.secret)
        auth = Auth.from_omniauth(@hash)
        auth.id.should eq(@auth.id)
        auth.token.should eq(@hash.credentials.token)
        auth.secret.should eq(@hash.credentials.secret)
      end
    end
    
    context 'if it does not exist' do
      before do
        @hash = OmniAuth.config.mock_auth[:desk]
      end
      
      it 'creates a new auth record' do
        auth = Auth.from_omniauth(@hash)
        auth.id.should_not be_nil
      end
      
      it 'saves the user to the auth' do
        auth = Auth.from_omniauth(@hash)
        auth2 = Auth.find auth.id
        auth2.user.should_not be_nil
      end
    end
  end
end
