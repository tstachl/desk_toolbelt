class Provider::Desk < Provider
  %w(cases customers interactions topics macros).each do |method|
    define_method(method) { |filter = {}| client(method, prepare_filter(filter)) }
  end
  
  %w(customer interaction).each do |method|
    define_method("create_#{method}") do |hash = {}|
      client("create_#{method}", hash)
    end
  end
  
  def create_case(hash = {})
    # get interactions if exist
    interactions = hash.delete('interactions')
    # get status if exists
    status = hash.delete('case_status')
    # create the case
    result = create_interaction(hash)
    # run through interactions if exist
    if result.case and result.case.id
      interactions.each do |interaction|
        if result.case and result.case.id
          interaction['case_id'] = result.case.id
          create_interaction(interaction)
        end
      end if interactions
      
      # set the status to resolved
      update_case(result.case.id, { case_status_type_id: status || 70 })
    end
    # return the initial result
    result
  end
  
  def update_case(id, hash = {})
    client("update_case", id, hash)
  end

  def create_topic(hash = {})
    # get articles if exist
    articles = hash.delete('articles')
    # create the topic
    result = client("create_topic", hash['name'], hash)
    # run through articles if exist
    if articles and result and result.id
      articles.each do |article|
        if result and result.id
          create_article(result.id, article)
        end
      end
    end
    # return the initial result
    result
  end
  
  %w(articles).each do |method|
    define_method(method) { |id = nil, filter = {}| client(method, id, prepare_filter(filter)) }
    define_method("create_#{method.singularize}") { |id = nil, hash = {}|
      hash['main_content'] = extract_images(hash['main_content'], hash['host'], hash['subject']) if hash.key?('main_content')
      client("create_#{method.singularize}", id, hash)
    }
    define_method("update_#{method.singularize}") { |id = nil, hash = {}| client("update_#{method.singularize}", id, hash) }
  end
  
protected
  def extract_images(main_content, host = '', subject = nil)
    main_content.tap do |content|
      content.scan(/<img[^>]+src="([^">]+)"/).each do |image|
        image_str = image.first
        Rails.logger.debug("Image: #{image_str}")
        # image
        image_uri = URI::parse(image_str)
        image_uri.scheme = 'https'
        image_uri.host = host unless image_uri.host and host
        Rails.logger.debug("Image URI: #{image_uri.to_s}")
        
        # get the name
        name = File.basename(image_uri.path)
        # zendesk stores the real name as a query parameter name
        params = CGI::parse(image_uri.query)
        name = params['name'].first if params.key?('name')
        Rails.logger.debug("File Name: #{name}")
        
        new_url = upload_image(name, image_uri, subject)
        Rails.logger.debug("New URL: #{new_url}")
        
        content[image_str] = new_url.to_s
      end
    end
  end

  def upload_image(name, url, subject)
    Rails.logger.debug("URL: #{url}")
    sitename = auth.site.name_clean.sanitize
    # sanitize the filename
    name = name.chomp(File.extname(name)).sanitize + File.extname(name)   
    # build the key
    key = "Toolbelt/#{Rails.env}/migration/#{sitename}/#{subject.sanitize}/#{SecureRandom.hex.first(8)}_#{name}"
    # upload the file
    file = AWS::S3.new.buckets[ENV['AWS_BUCKET']].objects[key]
    file.write(file: open(url.to_s))
    file.acl = :public_read
    file.public_url secure: true
  end
  
private
  def prepare_filter(filter)
    tmp = {}
    filter.each_pair{ |key, value| 
      tmp[key] = (DateTime.strptime(value, "%m/%d/%y").strftime("%s") rescue value)
    }
    tmp
  end
  
  def client(method, *args)
    get_client.send method, *args
  rescue ::Desk::TooManyRequests
    # sleep 5 seconds and try again
    sleep(5)
    client method, *args
  end

  def get_client
    @client ||= ::Desk.client({
      subdomain: auth.site.name, 
      oauth_token: auth.token, 
      oauth_token_secret: auth.secret
    })
  end
end