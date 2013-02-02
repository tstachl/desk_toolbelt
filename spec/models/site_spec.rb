require 'spec_helper'

describe Site do
  context 'has to be valid and' do
    before do
      @site = Site.new
      @present = Site.create :name => 'unique.desk.com'
    end
    
    it 'must have a name' do
      is_valid(@site, :name, 'some.desk.com')
    end
    it 'must have a unique name' do
      is_valid(@site, :name, 'unique.desk.com', 'devel.desk.com')
    end
    it 'must have a domain name as name' do
      is_valid(@site, :name, 'nodomain', 'devel.desk.com')
    end
  end
  
  context '#name_clean' do
    it 'returns the titleized subdomain' do
      Site.new(name: 'https://devel.desk.com').name_clean.should == 'Devel'
    end
    
    it "doesn't look at the domain as long as desk is in it" do
      Site.new(name: 'https://zzz-dan.desk-staging.com').name_clean.should == 'Zzz Dan'
    end
  end
  
  context '#uri?' do
    it 'returns true if name is a uri' do
      Site.new(name: 'https://devel.desk.com').uri?.should be_true
    end
    
    it 'returns false if the name is not a uri' do
      Site.new(name: 'devel').uri?.should be_false
    end
  end
end
