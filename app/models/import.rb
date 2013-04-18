require 'csv'
require 'oj'
require 'ox'

class Import < ActiveRecord::Base
  POSSIBLE_ATTRIBUTES = {
    cases: %w(interaction_subject customer_id customer_twitter customer_email customer_name customer_language case_id external_id case_labels case_language interaction_channel interaction_body customer_custom_* case_custom_*),
    customers: %w(name company title description external_id email phone language custom_*),
    cases: %w(interaction_subject customer_id customer_twitter customer_email customer_name customer_language case_id external_id case_labels case_language interaction_channel interaction_body customer_custom_* case_custom_*),
    topics: %w(name description show_in_portal),
    macros: %w(name enabled labels),
    articles: %w(subject main_content published show_in_portal agent_content email chat twitter question phone quickcode language)
  }
  
  belongs_to :auth
  attr_accessible :description, :file, :format, :is_imported, :is_importing, :method, :type, :logfile
  
  # if we have a csv file we need to know what object to push the data in
  validates_presence_of :method, if: Proc.new { |import| import.format == 'csv' }
  validates_presence_of :auth
  validates_presence_of :format
  validates_attachment_presence :file
  
  has_attached_file :file, path: "tempfiles/exporter/#{Rails.env}/import/:filename"
  has_attached_file :logfile, path: "tempfiles/exporter/#{Rails.env}/logfiles/:filename"
  
  after_create { |import| Import.delay.run import.id }
  before_validation { |import| import.format = File.extname(file_file_name)[1..-1] }
  
  def import_json
    Rails.logger.info("Importing a json file.")
    import_hash Oj.load(open(file.expiring_url(300)).read)
  end
  
  def import_xml
    Rails.logger.info("Importing a xml file.")
    import_hash Hash.from_xml open(file.expiring_url(300)).read
  end
  
  def import_csv
    Rails.logger.info("Importing a csv file.")
    header = nil
    CSV.parse(open(file.expiring_url(300)).read) do |row|
      create_element(method, Hash[header.zip row]) if header
      header ||= row
    end
  end

  def import_xlf
    Rails.logger.info("Importing a xliff file.")
    doc = Ox.parse(open(file.expiring_url(300)).read)
    doc.root.nodes.each do |n|
      if n.value == 'file'
        update_element(:articles, get_id(n), { 
          language: get_language(n),
          subject: get_translation_for_key('subject', n),
          main_content: get_translation_for_key('main_content', n),
          agent_content: get_translation_for_key('agent_content', n),
          email: get_translation_for_key('email', n),
          chat: get_translation_for_key('chat', n),
          twitter: get_translation_for_key('twitter', n),
          question: get_translation_for_key('question', n),
          phone: get_translation_for_key('phone', n)
        })
      end
    end
  end
  
  def import
    begin
      Rails.logger.info("Creating a templog file.")
      @tmplog = Tempfile.new(['import', '.log'])
      @tmplog.write(open(logfile.expiring_url(300)).read) if logfile.expiring_url(300)
    
      Rails.logger.info("Importing: #{format}")
      send "import_#{format}" if respond_to? "import_#{format}".to_sym
    
      Rails.logger.info("Saving log file.")
      @tmplog.rewind
      update_attribute(:logfile, @tmplog)
    ensure
      Rails.logger.info("Removing the temp log file.")
      @tmplog.close
      @tmplog.unlink
    end
  end
  
protected
  def logger
    @_logger ||= Logger.new(@tmplog)
  end
  
  def import_hash(hash)
    if hash.kind_of? Hash
      hash.each_pair do |method, elements|
        elements.each do |element|
          create_element method, element.kind_of?(Array) ? element.last : element
        end
      end
    end
  end
  
  def create_element(method, hash)
    if auth.provider.respond_to? "create_#{method.to_s.singularize}"
      Rails.logger.info("Creating Element with method #{method}:")
      logger.info("==== Importing `#{method.to_s.singularize}': ==== #{hash.to_s}")
      auth.provider.send "create_#{method.to_s.singularize}", validate_and_extract_attributes(method, hash)
    else
      logger.info("==== FAILED: #{method.to_s.singularize.titleize} not supported yet. ====")
    end
  rescue Desk::InternalServerError
    # we know from test, Desk throws this error if eg. a customer already exists.
    logger.error("==== FAILED: The last element has not been imported. ====")
  rescue Desk::TooManyRequests
    # sleep 5 seconds and try again
    sleep(5)
    create_element method, element
  end

  def update_element(method, id, hash)
    if auth.provider.respond_to? "update_#{method.to_s.singularize}"
      Rails.logger.info("Translating #{method.to_s.singularize}:")
      logger.info("==== Translating `#{method.to_s.singularize}': #{id} ====")
      auth.provider.send "update_#{method.to_s.singularize}", id, validate_and_extract_attributes(method, hash)
    else
      logger.error("==== FAILED: Method update_#{method.to_s.singularize} not supported. ====")
    end
  rescue Desk::InternalServerError
    # we know from test, Desk throws this error if eg. a customer already exists.
    logger.error("==== FAILED: The last translation has not been imported. ====")
  rescue Desk::TooManyRequests
    # sleep 5 seconds and try again
    sleep(5)
    update_element method, id, hash
  end
  
  def validate_and_extract_attributes(method, hash)
    if POSSIBLE_ATTRIBUTES.key? method.to_sym
      hash.keep_if do |key, value|
        pattrs = POSSIBLE_ATTRIBUTES[method.to_sym]
        pattrs.include?(key.to_s) or pattrs.select{ |k| k.include?('*') and key.to_s.start_with?(k[0..-2]) }.size > 0
      end
    end
  end
  
  def get_id(node)
    node.attributes[:original]
  end

  def get_language(node)
    node.attributes[:'target-language']
  end

  def get_translation_for_key(key, node)
    # body = node.nodes.first
    transunit = node.nodes.first.nodes.select{ |n|
      # now we have the trans-unit
      n.attributes.key?(:id) && n.attributes[:id] == key
    }.first

    if transunit
      translation = transunit.nodes.select{ |n| n.value == 'target' }.first
      if translation && translation.attributes[:state] == 'translated'
        translation.nodes.first.value
      end
    end
  end
  
  class << self
    def run(id)
      Rails.logger.info("Starting import with ID: #{id}")
      import = find(id)
      Rails.logger.info("Set :is_importing to true")
      import.update_attribute(:is_importing, true)
      Rails.logger.info("Starting the actual import")
      import.import
      Rails.logger.info("Updating :is_importing to false and :is_imported to true")
      import.update_attributes(is_importing: false, is_imported: true)
    end
  end
end
