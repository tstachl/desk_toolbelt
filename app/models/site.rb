class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :auths
  
  validates :name, :presence => true, :uniqueness => true, :domain => true
  
  def name_clean
    name.match(/^https?:\/\/(?:([^\.]+)\.)?desk.*\.com\/?$/)[1].titleize
  end
end
