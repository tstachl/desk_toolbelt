class Provider::Desk < Provider
  def client
    @client ||= ::Desk.client({
      subdomain: auth.site.name, 
      oauth_token: auth.token, 
      oauth_token_secret: auth.secret
    })
  end
  
  # def markup_create
  #   {
  #     :case     => client.cases(count: 1).results.first.case.keys.keep_if{ |key| key =~ /custom_/ }.map{ |item|
  #       {
  #         name: item,
  #         type: nil
  #       }
  #     },
  #     :customer => client.customers(count: 1).results.first.customer.keys.keep_if{ |key| key =~ /custom_/ }.map{ |item|
  #       {
  #         name: item,
  #         type: nil
  #       }
  #     }
  #   }
  # end
  
  # def markup
  #   @@markup ||= ({}).tap do |markup|
  #     SUPPORTED_TYPES.each do |item|
  #       markup[item] = JSON.parse(File.new("#{Rails.root}/app/models/provider/desk/#{item.to_s}.json").read)
  #     end
  #   end
  # end
  
  %w(cases interactions customers).each do |method|
    define_method(method) { |filter = {}| client.send(method, prepare_filter(filter)) }
  end
  
  def create_case(hash)
    # get interactions if exist
    interactions = hash.delete('interactions')
    # create the case
    result = create_interaction(hash)
    # run through interactions if exist
    if interactions and result.case and result.case.id
      interactions.each do |interaction|
        if result.case and result.case.id
          interaction['case_id'] = result.case.id
          create_interaction(interaction)
        end
      end
    end
    # return the initial result
    result
  end
  
  def create_interaction(hash)
    client.create_interaction(hash)
  end
  
  def create_customer(hash)
    client.create_customer(hash)
  end
  
  def create_topic(hash)
    # get articles if exist
    articles = hash.delete('articles')
    # get name
    name = hash.delete('name')
    # create the topic
    result = client.create_topic(name, hash)
    # run through articles if exist
    if articles and result and result.id
      articles.each do |article|
        if result and result.id
          article['topic_id'] = result.id
          create_article(article)
        end
      end
    end
    # return the initial result
    result
  end
  
  def create_article(hash)
    topic_id = hash.delete('topic_id')
    client.create_article(topic_id, hash)
  end
private
  def prepare_filter(filter)
    tmp = {}
    filter.each_pair do |key, value| 
      tmp[key] = (DateTime.strptime(value, "%m/%d/%y").strftime("%s") rescue value)
    end
    tmp
  end
end