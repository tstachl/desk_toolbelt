class Migration < ActiveRecord::Base
  belongs_to :to, class_name: 'Auth'
  belongs_to :from, class_name: 'Auth'
  
  attr_accessible :articles, :cases, :customers, :interactions, :topics
  
  validates :to, presence: true
  validates :from, presence: true
  
  def process_part(tempfile, method, not_first)
    tempfile << "#{not_first ? ', ' : ''}\"#{method}\":["
    pages = (from.provider.get_count(method)/Export::DEFAULT_MAX_COUNT.to_f).ceil
    (1..pages).each do |page|
      Rails.logger.info("Exporting `#{method.titleize}' page #{page} of #{pages} pages.")
      array = from.provider.send(method.to_sym, { page: page, count: Export::DEFAULT_MAX_COUNT })
      array.each do |item|
        tempfile << item.to_json.concat((page == pages && array.last == item) ? '' : ',')
      end
    end
    tempfile << "]"
  end
  
  def process_migration
    Rails.logger.info("Creating the tempfile for the migration.")
    tempfile = Tempfile.new(["#{Time.now.strftime('%Y%m%d%H%M%S')}", ".json"])
    tempfile << "{"
    
    # customers
    process_part tempfile, 'customers', false if customers
    process_part tempfile, 'cases', !!customers if cases
    process_part tempfile, 'topics', !!customers or !!cases if topics
    
    tempfile << "}"
    tempfile
  end
  
  def migrate
    tempfile = process_migration
    # create a new import with the file
    Rails.logger.info("Removing the tempfile.")
    tempfile.close
    tempfile.unlink
  end
end
