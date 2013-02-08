require 'spec_helper'

describe MigrationsController do

  describe "GET 'desk'" do
    it "returns http success" do
      get 'desk'
      response.should be_success
    end
  end

  describe "GET 'zendesk'" do
    it "returns http success" do
      get 'zendesk'
      response.should be_success
    end
  end

  describe "GET 'select'" do
    it "returns http success" do
      get 'select'
      response.should be_success
    end
  end

  describe "GET 'mapping'" do
    it "returns http success" do
      get 'mapping'
      response.should be_success
    end
  end

  describe "GET 'finish'" do
    it "returns http success" do
      get 'finish'
      response.should be_success
    end
  end

end
