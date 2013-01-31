class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :auths
  
  validates :name, :presence => true, :uniqueness => true, :domain => true
  
  attr_accessible :name
  
  def name_clean
    name.match(/\Ahttps?:\/\/(?:([^\.]+)\.)?desk.*\.com\/?\z/)[1].titleize
  end
end
