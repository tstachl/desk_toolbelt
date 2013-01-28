class User < ActiveRecord::Base
  has_many :sites, :through => :auths
  has_many :auths, :autosave => true do
    def create_from_omniauth(hash)
      auth = Auth.find_or_initialize_by_omniauth hash
      auth.update_attributes :user => proxy_association.owner, :site => Site.find_or_create_by_name(hash.site)
    end
  end
  belongs_to :role, :autosave => true
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validates :role, presence: true
  
  def update_omniauth(hash)
    update_attributes({
      :name => hash.info.name_public,
      :role => Role.find_or_create_by_name({ :name => hash.info.user_level })
    })
  end
  
  def gravatar(size = 20)
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"
  end
  
  class << self
    def find_or_initialize_by_omniauth(hash)
      User.find_or_initialize_by_email({
        :name => hash.info.name_public,
        :email => hash.info.email
      })
    end
  end
end
