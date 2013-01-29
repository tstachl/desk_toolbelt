require 'spec_helper'

describe SessionsController do

  describe "GET 'new'" do
    context "user logged in" do
      before do
        auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = auth.id
      end
      
      it "redirects to the home page" do
        get :new
        response.should redirect_to root_url
      end
    end
    
    context "user logged out" do
      it "renders the :new template" do
        get :new
        response.should render_template :new
      end
    end
  end

  describe "POST 'create'", moved: true do
    context "with valid attributes" do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:desk]
      end
      
      it "saves a new auth record in the database" do
        expect{
          post :create, :provider => 'desk'
        }.to change(Auth, :count).by 1
      end
      
      it "sets a flash success message" do
        post :create, :provider => 'desk'
        flash[:success].should_not be_nil
      end
      
      it "redirects to the home page" do
        post :create, :provider => 'desk'
        response.should redirect_to root_path
      end
      
      it "sets the session" do
        post :create, :provider => 'desk'
        session[:aid].should_not be_nil
      end
      
      it "sets the current_auth" do
        post :create, :provider => 'desk'
        controller.current_auth.should be_kind_of Auth
      end
    end
    
    context "with invalid attributes" do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:zendesk]
      end
      
      it "does not save a new auth record in the database" do
        expect {
          post :create, :provider => 'zendesk'
        }.to change(Auth, :count).by 0
      end
      
      it "redirects to the failure route page" do
        post :create, :provider => 'zendesk'
        response.should redirect_to :action => :failure, :message => "This authorization process doesn't allow Zendesk as a Service Provider."
      end
    end

    context "without attributes" do
      it "redirects to the failure route if no hash" do
        post :create, :provider => 'desk'
        response.should redirect_to :action => :failure, :message => "Something went wrong, please try again in a few minutes or contact your administrator."
      end
    end
  end

  describe "DELETE 'destroy'" do
    context "user logged in" do
      before do
        auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
        session[:aid] = auth.id
      end
      
      it "resets the session to nil" do
        delete :destroy
        session[:aid].should be_nil
      end
      
      it "redirects to the login page" do
        delete :destroy
        response.should redirect_to login_path
      end

      it "sets a flash info message" do
        delete :destroy
        flash[:info].should_not be_nil
      end
    end
    
    context "user logged out" do
      it "redirects to the login page" do
        delete :destroy
        response.should redirect_to login_path
      end
    end
  end

  describe "GET 'failure'" do
    it "redirects to the login page" do
      get :failure, :message => 'Some error.'
      response.should redirect_to login_path
    end
    
    it "sets a flash error message" do
      get :failure, :message => 'Some Error.'
      flash[:error].should_not be_nil
    end
  end
end
