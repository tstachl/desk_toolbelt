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
end
