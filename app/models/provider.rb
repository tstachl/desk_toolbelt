class Provider < ActiveRecord::Base
  SUPPORTED_TYPES = [:case, :interaction, :customer, :topic, :article]
  
  has_many :auths
  attr_accessible :type, :name
  attr_accessor :auth
  
  def markup; raise "This method must be redefined in the subclass"; end
  def markup_create; raise "This method must be redefined in the subclass"; end
  
  def cases(filter = {}); raise "This method must be redefined in the subclass"; end
  def case(case_id); raise "This method must be redefined in the subclass"; end
  def update_case(case_id, options = {}); raise "This method must be redefined in the subclass"; end
  def create_case(options = {}); raise "This method must be redefined in the subclass"; end
  
  def interactions(case_id_or_filter = {}); raise "This method must be redefined in the subclass"; end
  def interaction(comment_id); raise "This method must be redefined in the subclass"; end
  def update_interaction(comment_id, options = {}); raise "This method must be redefined in the subclass"; end
  def create_interaction(options = {}); raise "This method must be redefined in the subclass"; end
  
  def customers(filter = {}); raise "This method must be redefined in the subclass"; end
  def customer(customer_id); raise "This method must be redefined in the subclass"; end
  def update_customer(customer_id, options = {}); raise "This method must be redefined in the subclass"; end
  def create_customer(options = {}); raise "This method must be redefined in the subclass"; end
  
  def topics(filter = {}); raise "This method must be redefined in the subclass"; end
  def topic(topic_id); raise "This method must be redefined in the subclass"; end
  def update_topic(topic_id, options = {}); raise "This method must be redefined in the subclass"; end
  def create_topic(options = {}); raise "This method must be redefined in the subclass"; end
  
  def articles(topic_id_or_filter = {}); raise "This method must be redefined in the subclass"; end
  def article(article_id); raise "This method must be redefined in the subclass"; end
  def update_article(article_id, options = {}); raise "This method must be redefined in the subclass"; end
  def create_article(options = {}); raise "This method must be redefined in the subclass"; end
end