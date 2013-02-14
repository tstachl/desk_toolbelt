require 'spec_helper'

describe AuthsController do
  render_views
  before(:each) do
    FactoryGirl.create :provider
    FactoryGirl.create :provider_zendesk
  end
  
  describe "GET 'index'" do
    before do
      @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
      session[:aid] = @auth.id
    end
    
    it "populates an array of auths" do
      get :index
      assigns(:auths).should eq([@auth])
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end
  
  describe "GET 'new'" do
    before do
      @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
      session[:aid] = @auth.id
    end
    
    it "assigns auth" do
      get :new
      assigns(:auth).should be_new_record
    end
    
    it "returns modal version if xhr request" do
      xhr :get, :new
      response.body.should =~ /modal-header/
    end
  end
  
  describe "POST 'create'" do
    context "user exists" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      context "with valid attributes" do
        before do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:desk_dan]
        end

        it "saves a new auth record in the database" do
          expect{
            post :create, provider: 'desk'
          }.to change(Auth, :count).by 1
        end

        it "sets a flash success message" do
          post :create, provider: 'desk'
          flash[:success].should_not be_nil
        end

        it "redirects to index" do
          post :create, provider: 'desk'
          response.should redirect_to action: :index
        end
      end
    end
    
    context "user doesn't exist" do
      context "with valid attributes" do
        before do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:desk_dan]
        end

        it "saves a new auth record in the database" do
          expect{
            post :create, provider: 'desk'
          }.to change(Auth, :count).by 1
        end

        it "sets a flash success message" do
          post :create, provider: 'desk'
          flash[:success].should_not be_nil
        end

        it "redirects to index" do
          post :create, provider: 'desk'
          response.should redirect_to controller: :sessions, action: :index
        end

        it "sets the session" do
          post :create, provider: 'desk'
          session[:aid].should_not be_nil
        end
        
        it "sets the current_auth" do
          post :create, provider: 'desk'
          controller.current_auth.should be_kind_of Auth
        end
      end

      context "with invalid attributes" do
        before do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:zendesk]
        end

        it "does not save a new auth record in the database" do
          expect {
            post :create, provider: 'zendesk'
          }.to change(Auth, :count).by 0
        end

        it "redirects to the failure route page" do
          post :create, provider: 'zendesk'
          response.should redirect_to controller: :sessions, action: :failure, message: "This authorization process doesn't allow Zendesk as a Service Provider."
        end
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    context "user logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
      end
      
      it "deletes the auth from the database" do
        expect {
          delete :destroy, id: @auth.id
        }.to change(Auth, :count).by -1
      end
      
      context "current authorization has been deleted" do
        context "user has another authorization" do
          before do
            @auth2 = Auth.login_omniauth OmniAuth.config.mock_auth[:desk_dan]
          end

          it "sets a flash success message" do
            delete :destroy, id: @auth.id
            flash[:success].should_not be_nil
          end

          it "sets a flash info message" do
            delete :destroy, id: @auth.id
            flash[:info].should_not be_nil
          end

          it "redirects to index" do
            delete :destroy, id: @auth.id
            response.should redirect_to action: :index
          end
          
          it "should change the session authorization id to the other one" do
            delete :destroy, id: @auth.id
            session[:aid].should == @auth2.id
          end
        end
      
        context "user doesn't have another authorization" do
          it "sets a flash info message" do
            delete :destroy, id: @auth.id
            flash[:info].should_not be_nil
          end
        
          it "redirects to login" do
            delete :destroy, id: @auth.id
            response.should redirect_to login_path
          end
        end
      end
      
      context "any other authorization has been deleted" do
        before do
          @auth2 = Auth.login_omniauth OmniAuth.config.mock_auth[:desk_dan]
        end
          
        it "sets a flash success message" do
          delete :destroy, id: @auth2.id
          flash[:success].should_not be_nil
        end

        it "redirects to index" do
          delete :destroy, id: @auth2.id
          response.should redirect_to action: :index
        end
      end
    end
    
    context "user logged out" do
      it "redirects to the login page" do
        delete :destroy, id: 1
        response.should redirect_to login_path
      end
    end
  end
  
  describe "GET 'change'" do
    context "user logged in" do
      before do
        @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = @auth.id
        
        @auth2 = Auth.login_omniauth OmniAuth.config.mock_auth[:desk_dan]
      end
      
      it "changes the current_auth" do
        get :change, id: @auth2.id
        session[:aid].should == @auth2.id
      end
      
      it "sets a flash info" do
        get :change, id: @auth2.id
        flash[:info].should_not be_nil
      end
      
      it "redirects to index" do
        get :change, id: @auth2.id
        response.should redirect_to action: :index
      end
    end
  end
end
