class Migration < ActiveRecord::Base
  belongs_to :to, class_name: 'Auth'
  belongs_to :from, class_name: 'Auth'
  
  attr_accessible :articles, :cases, :customers, :interactions, :topics
  
  def setup_mapping
  end

  def cases_mapping
    # check if we have the markup for desk and zendesk
    # :key = Mapping.get to.provider, :cases
    # if to.provider == 'desk'
    #   :cases
    # elsif to.provider == 'zendesk'
    #   :tickets
    # {
    #   to: to.,
    #   from: fields,
    #   map: 
    # }
  end
  
end
