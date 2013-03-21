require 'spec_helper'

describe MigrationsController do
  render_views
  before(:each) do
    FactoryGirl.create :provider
    FactoryGirl.create :provider_zendesk
  end

  describe "GET 'desk'" do
    it "returns http success" do
      get 'desk'
      response.should be_success
    end
    
    context "if logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      it "resets the session" do
        get 'desk'
        session[:aid].should be_nil
      end
    end
  end

  describe "GET 'zendesk'" do
    context "not logged in" do
      it "redirects back to #desk" do
        get :zendesk
        response.should redirect_to action: :desk
      end
    
      it "shows a flash error" do
        get :zendesk
        flash[:error].should_not be_nil
      end
    end
    
    context "if logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      it "clears the zendesk session" do
        session[:zendesk] = true
        get :zendesk
        session[:zendesk].should be_nil
      end
      
      it "assigns a new auth" do
        get :zendesk
        assigns(:auth).should_not be_nil
      end
      
      context "zendesk auth created" do
        before do
          @zenauth = Auth.from_omniauth OmniAuth.config.mock_auth[:zendesk]
          get :zendesk, auth_id: @zenauth.id
        end
        
        it "assigns the zendesk session parameter" do
          session[:zendesk].to_i.should eq @zenauth.id
        end
        
        it "shows a flash success message" do
          flash[:success].should_not be_nil
        end
        
        it "redirects to #selection" do
          response.should redirect_to action: :select
        end
      end
    end
  end

  describe "GET 'select'" do
    context "not logged in" do
      it "redirects back to #desk" do
        get :zendesk
        response.should redirect_to action: :desk
      end
    
      it "shows a flash error" do
        get :zendesk
        flash[:error].should_not be_nil
      end
    end
    
    context "if logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      context "without zendesk auth" do
        it "redirects back to #zendesk" do
          get :select
          response.should redirect_to action: :zendesk
        end
        
        it "shows a flash error" do
          get :select
          flash[:error].should_not be_nil
        end
      end
      
      context "with zendesk auth" do
        before do
          @zenauth = Auth.from_omniauth OmniAuth.config.mock_auth[:zendesk]
          session[:zendesk] = @zenauth.id
          get :select
        end
        
        it "assigns a new migration" do
          assigns(:migration).should_not be_nil
        end
        
        it "assigns the desk auth" do
          assigns(:migration).to.should eq @auth
        end
        
        it "assigns the zendesk auth" do
          assigns(:migration).from.should eq @zenauth
        end
      end
    end
  end
  
  describe "POST 'create'" do
    context "not logged in" do
      it "redirects to login" do
        post :create
        response.should redirect_to login_path
      end
      
      it "shows a flash error" do
        post :create
        flash[:error].should_not be_nil
      end
    end
    
    context "if logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      context "without valid attributes" do
        it "doesn't save the migration" do
          expect {
            post :create, migration: Migration.new
          }.not_to change(Migration, :count).by 1
        end
        
        it "renders #new" do
          post :create, migration: Migration.new
          response.should render_template :new
        end
        
        it "shows a flash error" do
          post :create, migration: Migration.new
          flash[:error].should_not be_nil
        end
      end
      
      context "with valid attributes" do
        before do
          @zenauth = Auth.from_omniauth(OmniAuth.config.mock_auth[:zendesk])
          session[:zendesk] = @zenauth.id
          @migration = FactoryGirl.attributes_for(:migration, from: nil, to: nil)
        end
        
        it "saves the migration using current_auth and session[:zendesk]" do
          expect {
            post :create, migration: @migration
          }.to change(Migration, :count).by 1
        end
        
        it "saves the migration with from_id and to_id set" do
          @migration = FactoryGirl.attributes_for(:migration, from_id: @zenauth.id, to_id: @auth.id)
          expect {
            post :create, migration: @migration
          }.to change(Migration, :count).by 1
        end
        
        it "redirects to index or to defined route" do
          session[:return_to] = migrations_finish_path
          post :create, migration: @migration
          response.should redirect_to migrations_finish_path
        end
        
        it "sets a flash success message" do
          post :create, migration: @migration
          flash[:success].should_not be_nil
        end
      end
    end
  end
  
  # describe "GET 'mapping'", :pending do
  #   it "returns http success" do
  #     get 'mapping'
  #     response.should be_success
  #   end
  # end

  describe "GET 'finish'", :pending do
    it "returns http success" do
      get 'finish'
      response.should be_success
    end
  end

end
