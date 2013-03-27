require 'yajl'

class Import < ActiveRecord::Base
  belongs_to :auth
  belongs_to :migration
  
  attr_accessible :description, :is_importing, :is_imported, :file, :migration, :is_error, :messages
  
  validates :auth, presence: true
  validates :file, presence: true
  
  has_attached_file :file,
    path: "tempfiles/exporter/#{Rails.env}/import/:filename"
  
  def import
    hash = Yajl::Parser.parse open(URI.parse(file.url))
    hash.each_pair do |method, data|
      data.each do |item|
        result = auth.provider.send "create_#{method.singularize}", item
      end
    end
  end
  
  class << self
    # run the import through background jobs
    def run(id)
      Rails.logger.info("Starting import with ID: #{id}")
      import = find(id)
      Rails.logger.info("Set :is_importing to true")
      import.update_attribute(:is_importing, true)
      Rails.logger.info("Starting the import.")
      import.import
      Rails.logger.info("Set :is_imported to true")
      import.update_attribute(:is_imported, true)
    end
  end
end
