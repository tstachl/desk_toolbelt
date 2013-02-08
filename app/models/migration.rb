class Migration < ActiveRecord::Base
  belongs_to :to, class_name: 'Auth'
  belongs_to :from, class_name: 'Auth'
  
  attr_accessible :articles, :cases, :customers, :interactions, :topics
end
