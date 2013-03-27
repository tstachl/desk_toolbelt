class Provider::Desk < Provider
  def client
    @client ||= ::Desk.client({
      subdomain: auth.site.name, 
      oauth_token: auth.token, 
      oauth_token_secret: auth.secret
    })
  end
  
  def markup_create
    @@markup_create ||= ({}).tap do |markup|
      SUPPORTED_TYPES.each do |item|
        markup[item] = JSON.parse(File.new("#{Rails.root}/app/models/provider/desk/#{item.to_s}_create.json").read)
      end
    end
  end
  
  def markup
    @@markup ||= ({}).tap do |markup|
      SUPPORTED_TYPES.each do |item|
        markup[item] = JSON.parse(File.new("#{Rails.root}/app/models/provider/desk/#{item.to_s}.json").read)
      end
    end
  end
  
  %w(cases interactions customers).each do |method|
    define_method(method) { |filter = {}| client.send(method, prepare_filter(filter)) }
  end
private
  def prepare_filter(filter)
    tmp = {}
    filter.each_pair{ |key, value| 
      tmp[key] = (DateTime.strptime(value, "%m/%d/%y").strftime("%s") rescue value)
    }
    tmp
  end
end