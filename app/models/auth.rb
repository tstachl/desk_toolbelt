class AuthError < StandardError; end

class Auth < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  
  has_many :exports
  
  attr_accessible :provider, :uid, :token, :secret, :user, :site
  
  validates :provider, :presence => true
  validates :uid, :presence => true
  validates :user, :presence => true
  validates :token, :presence => true
  
  def update_omniauth(hash)
    update_attributes({
      :token => hash.credentials.token,
      :secret => hash.credentials.secret
    })
  end
  
  class << self
    def find_or_initialize_by_omniauth(hash)
      Auth.find_or_initialize_by_uid({
        :provider => hash.provider,
        :uid => hash.uid.to_s,
        :token => hash.credentials.token,
        :secret => hash.credentials.secret
      })
    end
    
    def login_omniauth(hash)
      raise AuthError, "Something went wrong, please try again in a few minutes or contact your administrator." unless hash
      raise AuthError, "This authorization process doesn't allow #{hash.provider.to_s.titleize} as a Service Provider." unless hash.provider == 'desk'
      from_omniauth hash
    end
    
    def from_omniauth(hash, user = nil)
      auth = Auth.find_or_initialize_by_omniauth hash
      
      if auth.new_record?
        auth.update_attributes({
          :user => user || User.find_or_initialize_by_omniauth(hash),
          :site => Site.find_or_create_by_name(hash.info.site)
        })
      else
        auth.update_omniauth(hash)
      end
      
      auth.user.update_omniauth(hash)
      auth.save
      auth
    end
  end
end
