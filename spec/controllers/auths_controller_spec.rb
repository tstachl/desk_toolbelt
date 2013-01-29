require 'spec_helper'

describe AuthsController do
  
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
end
