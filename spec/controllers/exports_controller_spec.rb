require 'spec_helper'

describe ExportsController do
  render_views
  before(:each) do
    FactoryGirl.create :provider
    FactoryGirl.create :provider_zendesk
    @auth = Auth.login_omniauth OmniAuth.config.mock_auth[:desk]
    session[:aid] = @auth.id
  end

  describe "GET #index" do
    before do
      Export.any_instance.stub(:save_attached_files).and_return(true)
      @exports = []
      5.times{
        @exports.push(FactoryGirl.create(:exported_export, auth: @auth))
      }
    end
    
    it "populates an array of exports" do
      get :index
      assigns(:exports).should eq(@exports)
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end
  
  describe "GET #new" do
    before do
      @filter = FactoryGirl.build(:preview_export, auth: @auth).filter
      stub_request(:get, /.*devel\.desk\.com.*/).
         to_return(body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'))
    end
    
    it "assigns export" do
      get :new, type: 'case', case: @filter
      assigns(:export).should be_new_record
    end
    
    it "returns modal version if xhr request" do
      xhr :get, :new, type: 'case', case: @filter
      response.body.should =~ /modal-header/
    end
  end
  
  describe "POST #create" do
    before do
      @export = FactoryGirl.build(:export, auth: @auth)
    end
    
    context "with valid attributes" do
      it "saves a new auth record in the database" do
        expect{
          post :create, export: { 
            filter: @export.filter.to_json, 
            method: @export.method, 
            description: @export.description, 
            format: @export.format, 
            total: @export.total, 
            pages: @export.pages
          }
        }.to change(Export, :count).by 1
      end
  
      it "sets a flash success message" do
        post :create, export: { 
          filter: @export.filter.to_json, 
          method: @export.method, 
          description: @export.description, 
          format: @export.format, 
          total: @export.total, 
          pages: @export.pages
        }
        flash[:success].should_not be_nil
      end
  
      it "redirects to index" do
        post :create, export: { 
          filter: @export.filter.to_json, 
          method: @export.method, 
          description: @export.description, 
          format: @export.format, 
          total: @export.total, 
          pages: @export.pages
        }
        response.should redirect_to action: :index
      end
    end
    
    context "with invalid attributes" do
      before do
        @export.filter = nil
        @export.method = nil
        @export.format = nil
      end
      
      it "saves a new auth record in the database" do
        expect{
          post :create, export: { 
            filter: @export.filter.to_json, 
            method: @export.method, 
            description: @export.description, 
            format: @export.format, 
            total: @export.total, 
            pages: @export.pages
          }
        }.to_not change(Export, :count).by 1
      end
  
      it "sets a flash success message" do
        post :create, export: { 
          filter: @export.filter.to_json, 
          method: @export.method, 
          description: @export.description, 
          format: @export.format, 
          total: @export.total, 
          pages: @export.pages
        }
        flash[:error].should_not be_nil
      end
  
      it "redirects to index" do
        post :create, export: { 
          filter: @export.filter.to_json, 
          method: @export.method, 
          description: @export.description, 
          format: @export.format, 
          total: @export.total, 
          pages: @export.pages
        }
        response.should redirect_to action: :index
      end
    end
  end
  
  describe "DELETE #destroy" do
    before do
      @export = FactoryGirl.create(:export, auth: @auth)
    end
    
    context "simple delete" do
      it "deletes the export from the database" do
        expect {
          delete :destroy, id: @export.id
        }.to change(Export, :count).by -1
      end
      
      it "sets a success flash message" do
        delete :destroy, id: @export.id
        flash[:success].should_not be_nil
      end
      
      it "redirects to index" do
        delete :destroy, id: @export.id
        response.should redirect_to action: :index
      end
    end
    
    context "delete while exporting" do
      before do
        @export.update_attribute(:is_exporting, true)
      end
      
      it "doesn't get deleted while exporting" do
        expect {
          delete :destroy, id: @export.id
        }.to_not change(Export, :count).by -1
      end
      
      it "sets a flash info message" do
        delete :destroy, id: @export.id
        flash[:info].should_not be_nil
      end
      
      it "redirects to index" do
        delete :destroy, id: @export.id
        response.should redirect_to action: :index
      end
    end
    
    context "destroy fails" do
      before do
        @export.destroy
      end
      
      it "doesn't delete anything" do
        expect {
          delete :destroy, id: @export.id
        }.to_not change(Export, :count).by -1
      end
      
      it "sets a error flash message" do
        delete :destroy, id: @export.id
        flash[:error].should_not be_nil
      end
      
      it "redirects to index" do
        delete :destroy, id: @export.id
        response.should redirect_to action: :index
      end
    end
  end
end