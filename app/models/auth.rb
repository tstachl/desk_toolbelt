class AuthError < StandardError; end

class Auth < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :provider
  
  has_many :exports
  
  attr_accessible :provider, :uid, :user, :site
  attr_encrypted :secret, key: ENV['ENCRYPTION_KEY'], encode: true
  
  validates :provider, :presence => true
  validates :uid, :presence => true
  validates :user, :presence => true
  validates :token, :presence => true
  
  def update_omniauth(hash)
    if new_record?
      update_attributes({
        user: user || User.find_or_initialize_by_omniauth(hash),
        site: Site.find_or_create_by_name(hash.info.site)
      })
    end
    
    # Can't mass-assign protected attributes: token, secret
    token = hash.credentials.token
    secret = hash.credentials.secret
    # Update the user
    user.update_omniauth(hash)
    
    save
  end
  
  def client(max_requests = 10)
    Object.const_get("#{provider.name.capitalize}").client subdomain: site.name, oauth_token: token, oauth_token_secret: secret, max_requests: max_requests
  end
  
  class << self
    def find_or_initialize_by_omniauth(hash)
      auth = Auth.find_or_initialize_by_uid({
        provider: Provider.find_by_provider(hash.provider),
        uid: hash.uid.to_s
      })
      
      # Can't mass-assign protected attributes: token, secret
      auth.token = hash.credentials.token
      auth.secret = hash.credentials.secret
      
      auth
    end
    
    def login_omniauth(hash)
      raise AuthError, "Something went wrong, please try again in a few minutes or contact your administrator." unless hash
      
      auth = Auth.find_or_initialize_by_omniauth hash
      unless auth.provider == Provider.find_by_provider('desk')
        raise AuthError, "This authorization process doesn't allow #{hash.provider.to_s.titleize} as a Service Provider."
      end
      
      auth.update_omniauth hash
      auth
    end
    
    def from_omniauth(hash, user = nil)
      auth = Auth.find_or_initialize_by_omniauth hash
      auth.update_omniauth hash
      auth
    end
  end
end
