require 'spec_helper'

describe User do
  context 'has to be valid and' do
    before do
      @present = User.create({
        :name => Faker::Name.name,
        :email => Faker::Internet.email,
        :role => Role.new({ :name => Faker::Lorem.word })
      })
      @user = User.new
    end
      
    it 'validates the name a name is present' do
      is_valid(@user, :name, Faker::Name.name)
    end
    it 'validates the email address is present' do
      is_valid(@user, :email, Faker::Internet.email)
    end
    it 'validates the email address is unique' do
      is_valid(@user, :email, @present.email, Faker::Internet.email)
    end
    it 'valdiates the email address is an email address' do
      is_valid(@user, :email, ')something(', Faker::Internet.email)
    end
    it 'validates a role is present' do
      is_valid(@user, :role, Role.new({ :name => Faker::Lorem.word }))
    end
  end
  
  context 'has to work with omniauth hashes and' do
    context 'if the user exists' do
      before do
        @hash = OmniAuth.config.mock_auth[:desk]
        
        @user = User.create({
          :name => Faker::Name.name,
          :email => @hash.info.email,
          :role => Role.create(:name => 'siteadmin_billing')
        })
      end
      
      it 'can befound by omniauth' do
        user = User.find_or_initialize_by_omniauth @hash
        user.id.should eq(@user.id)
      end
      
      it 'update the user' do
        @user.update_omniauth(@hash)
        @user.name.should eq(@hash.info.name_public)
        @user.role.name.should eq(@hash.info.user_level)
      end
      
      it 'creates new authorizations' do
        expect {
          @user.auths.create_from_omniauth @hash
        }.to change(Auth, :count).by(1)
      end
    end
    
    context 'if the user does not exist' do
      before do
        @hash = OmniAuth.config.mock_auth[:desk]
      end
      
      it 'can initialize a new user with omniauth' do
        user = User.find_or_initialize_by_omniauth @hash
        user.should be_new_record
      end
    end
  end
end
