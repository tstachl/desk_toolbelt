class Export::Migration < Export
  attr_accessible :articles, :cases, :customers, :interactions, :topics
  belongs_to :from, class_name: 'Auth'
  before_validation :set_defaults
  after_update :create_import
  
  validates_presence_of :from
  
  def process_part(tempfile, method)
    # if tempfile.size is 1 we know it's the first
    tempfile << "#{tempfile.size != 1 ? ', ' : ''}\"#{method}\":["
    pages = (from.provider.get_count(method)/::Export::DEFAULT_MAX_COUNT.to_f).ceil
    (1..pages).each do |page|
      Rails.logger.info("Exporting `#{method.titleize}' page #{page} of #{pages} pages.")
      array = from.provider.send(method.to_sym, { page: page, count: ::Export::DEFAULT_MAX_COUNT })
      array.each do |item|
        tempfile << item.to_json.concat((page == pages && array.last == item) ? '' : ',')
      end
    end
    tempfile << "]"
  end
  
  def process_export
    Rails.logger.info("Creating the tempfile for the export.")
    tempfile = Tempfile.new(["#{Time.now.strftime('%Y%m%d%H%M%S')}_#{method}", ".#{format}"])

    tempfile << "{"
    
    process_part(tempfile, 'customers') if customers
    process_part(tempfile, 'cases') if cases
    process_part(tempfile, 'topics') if topics
    
    tempfile << "}"
    tempfile
  end
  
protected
  def set_defaults
    self.method = 'migration'
    self.format = 'json'
  end
  
  def create_import
    # :description, :file, :format, :is_imported, :is_importing, :method, :type, :logfile
    if self.is_exported
      import = Import.new
      import.auth = self.auth
      import.file = self.file
      
      if import.save
        MigrationMailer.delay.starting_import_email(self.id)
      else
        MigrationMailer.delay.create_import_failed_email(self.id)
      end
    end
  end
end