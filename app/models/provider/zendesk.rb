class Provider::Zendesk < Provider
  SUPPORTED_TYPES_MAP = {
    :case         => :ticket,
    :interaction  => :ticket_audit,
    :customer     => :user,
    :topic        => :forum,
    :article      => :topic
  }

  def client
    @client ||= ::ZendeskAPI::Client.new do |config|
      config.url      = "#{auth.site.name}/api/v2"
      config.username = auth.token
      config.password = auth.secret
    end
  end

  def markup
    {
      :case     => case_markup,
      :customer => JSON.parse(File.new("#{Rails.root}/app/models/provider/zendesk/user.json").read)
    }
  end
  
  def get_count(method)
    client.send(SUPPORTED_TYPES_MAP[method.to_s.singularize.to_sym].to_s.pluralize.to_sym).count
  end
  
  def cases(filter = {})
    collection = client.tickets.include(:users).page(filter.delete(:page)).per_page(filter.delete(:count)).map do |resource|
      inter = []
      if not filter.key?(:no_interactions) or not filter[:no_interactions]
        inter =  interactions(resource, true)
      end
      
      {
        interaction_subject: resource.subject,
        customer_email: resource.submitter.email,
        customer_name: resource.submitter.name,
        case_external_id: resource.external_id,
        case_labels: resource.tags.join(','),
        interaction_channel: resource.submitter.email.blank? ? 'phone' : 'email',
        interaction_body: resource.description,
        interactions: inter
      }
    end
  end
  
  def interactions(resource_or_case_id, skip_first = false)
    tmp = []
    resource_or_case_id = client.ticket.include(:users).find(id: resource_or_case_id) unless resource_or_case_id.class == ZendeskAPI::Ticket
    
    resource_or_case_id.audits.each_page do |resource|
      resource.events.each do |event|
        next unless ['comment', 'facebookevent', 'tweet', 'sms'].include?(event.type.downcase)

        if skip_first
          skip_first = false
          next
        end
        
        tmp.push({
          interaction_subject: resource.subject,
          interaction_body: event.body,
          customer_email: resource.author.email,
          customer_name: resource.author.name
        })
      end
    end
    
    tmp
  end
  
  def customers(filter = {})
    collection = client.users.include(:identities).page(filter.delete(:page)).per_page(filter.delete(:count)).select{ |resource| resource.role.id == 'end-user' }.map do |resource|
      twitter = nil
      if resource.identities.count > 1
        resource.identities.each_page do |identity|
          twitter = identity.value if identity.type == 'twitter'
        end
      end
      
      {
        name: resource.name,
        description: resource.notes,
        external_id: resource.external_id,
        email: resource.email,
        phone: resource.phone,
        twitter: twitter
      }
    end
  end
  
  def topics(filter = {})
    collection = client.forums.page(filter.delete(:page)).per_page(filter.delete(:count)).select{ |resource| resource.forum_type == 'articles' }.map do |resource|
      art = []
      if not filter.key?(:no_articles) or not filter[:no_articles]
        art =  articles(resource)
      end
      
      {
        id: resource.id,
        name: resource.name,
        description: resource.description,
        show_in_portal: resource.access != 'agents only',
        articles: art
      }
    end
  end
  
  def articles(resource_or_article_id)
    tmp = []
    resource_or_article_id = client.forums.find(id: resource_or_article_id) unless resource_or_article_id.class == ZendeskAPI::Forum
    
    resource_or_article_id.topics.each_page do |resource|
      tmp.push({
        subject: resource.title,
        main_content: resource.body,
        published: true,
        show_in_portal: true
      })
    end
    
    tmp
  end
private
  def case_markup
    kase = []
    client.ticket_fields.each_page{ |resource| kase.push({
      id: resource.id,
      name: resource.title.downcase,
      type: nil
    }) if resource.active }
    JSON.parse(File.new("#{Rails.root}/app/models/provider/zendesk/ticket.json").read).merge custom_fields: kase
  end
end