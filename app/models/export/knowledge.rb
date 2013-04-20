class Export::Knowledge < Export
  before_validation :set_defaults
  
  def topic_header(topic)
    if format == 'json'
      "{\"id\":#{topic.id},\"name\":#{topic.name.to_json},\"description\":#{topic.description.to_json},\"position\":#{topic.position},\"show_in_portal\":#{topic.show_in_portal},\"articles\":["
    else
      "<topic><id>#{topic.id}</id><name>#{coder.encode topic.name}</name><description>#{coder.encode topic.description}</description><position>#{topic.position}</position><show_in_portal>#{topic.show_in_portal}</show_in_portal><articles>"
    end
  end
  
  def topic_footer(last = false)
    if format == 'json'
      "]}".concat(last ? '' : ',')
    else
      "</articles></topic>"
    end
  end
  
  def get_topics
    self.method = 'topics'
    self.pages  = nil
    
    results = []
    page = 1
    
    begin
      Rails.logger.info("Fetching topics page #{page} of #{pages} pages.")
      fetch_export(Export::Knowledge::DEFAULT_MAX_COUNT, page)['results'].each do |item|
        results.push(Hashie::Mash.new({
          id: item.topic.id,
          name: item.topic.name,
          description: item.topic.description,
          position: item.topic.position,
          show_in_portal: item.topic.show_in_portal
        }))
      end
    end while (page += 1) <= pages
    
    self.method = nil
    self.pages  = nil
    
    results
  end
  
  def process_export
    Rails.logger.info("Creating the tempfile for the export.")
    tempfile = Tempfile.new(["#{Time.now.strftime('%Y%m%d%H%M%S')}_#{method}", ".#{format}"])
    
    Rails.logger.info("Fetching the topics for the export.")
    topics = get_topics
    
    if ['json', 'xml'].include? self.format
      Rails.logger.info("Writing the header for json and xml.")
      self.method = 'topics'
      tempfile << header
    end
    
    self.method = 'articles'
    
    topics.each do |topic|
      Rails.logger.info("Exporting articles for topic: #{topic.name} - #{topic.id}")
      next unless topic.id
      
      if ['json', 'xml'].include? self.format
        Rails.logger.info("Adding topic header for #{self.format} format.")
        tempfile << topic_header(topic)
      end
      
      # clear the pages before getting the articles of each topic
      self.pages = nil
      
      page = 1
      begin
        Rails.logger.info("Exporting page #{page} of #{pages} pages.")
        results = fetch_export(Export::DEFAULT_MAX_COUNT, page, topic.id)
        results['results'].each_index{ |index|
          article = results.results.at(index)
          if self.format == 'csv'
            article[:topic_id] = topic.id
            tempfile << header(article) if tempfile.size == 0
          end
          tempfile << row(article, ((page == self.pages) && (results.results.size == index + 1)))
        }
      end while (page += 1) <= self.pages
      self.pages = nil
      
      if ['json', 'xml'].include? self.format
        Rails.logger.info("Adding topic footer for #{self.format} format.")
        tempfile << topic_footer(topic == topics.last)
      end
    end
    
    if ['json', 'xml'].include? self.format
      Rails.logger.info("Writing the footer to the tempfile.")
      self.method = 'topics'
      tempfile << footer
    end
    tempfile
  end
  
protected
  def set_defaults
    self.method = 'knowledge_base'
  end

  def coder
    @_coder ||= HTMLEntities.new
  end
end