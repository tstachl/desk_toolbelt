require 'csv'
require 'tempfile'

class Export < ActiveRecord::Base
  DEFAULT_MAX_COUNT = 100
  
  belongs_to :auth
  serialize :filter
  attr_accessible :filter, :is_exported, :is_exporting, :method, :description, :format, :total, :pages, :file, :type
  
  validates_presence_of :filter, unless: Proc.new { |export| export.type == "Export::Knowledge" }
  validates_presence_of :method
  validates_presence_of :format
  validates_presence_of :auth
  
  has_attached_file :file
  
  after_create { |export| Export.delay.run export.id }
  
  def get_filter
    self.filter ||= {}
  end
  
  def preview
    fetch_and_update(10)
  end
  
  def header(item = nil)
    # write the file header
    if format == 'json'
      # write json header
      "{\"#{method}\":["
    elsif format == 'xml'
      # write the xml header
      "<#{method}>"
    else
      # write the csv header
      "#{item[method.singularize].keys.to_csv}"
    end
  end
  
  def row(item, last = false)
    # append to the file
    if format == 'json'
      # write json record
      item[method.singularize].to_json.concat(last ? '' : ',')
    elsif format == 'xml'
      # write xml record
      item[method.singularize].to_xml(root: method.singularize, skip_instruct: true)
    else
      # write the csv record
      item[method.singularize].values.map{ |v| Export.tabular_value(v) }.to_csv
    end
  end
  
  def footer
    # write the file footer
    if format == 'json'
      # write the json footer
      ']}'
    elsif format == 'xml'
      # write the xml footer
      "</#{method}>"
    end
  end
  
  def process_export
    Rails.logger.info("Creating the tempfile for the export.")
    tempfile = Tempfile.new(["#{Time.now.strftime('%Y%m%d%H%M%S')}_#{method}", ".#{format}"])

    page = 1
    begin
      Rails.logger.info("Exporting page #{page} of #{pages} pages.")
      results = fetch_export(Export::DEFAULT_MAX_COUNT, page)
      results['results'].each_index{ |index|
        tempfile << header(results['results'].at(index)) if tempfile.size == 0
        tempfile << row(results['results'].at(index), ((page == pages) && (results['results'].size == index + 1)))
      }
    end while (page += 1) <= pages

    Rails.logger.info("Writing the footer to the tempfile.")
    tempfile << footer
    tempfile
  end
  
  def export
    tempfile = process_export
    tempfile.rewind
    
    update_attribute(:file, tempfile)
    
    Rails.logger.info("Removing the tempfile.")
    tempfile.close
    tempfile.unlink
  end
  
private
  def fetch count, page = 1, id = nil
    return auth.provider.send method, get_filter.merge(page: page, count: count) unless id
    auth.provider.send method, id, get_filter.merge(page: page, count: count)
  end
  
  def fetch_and_update count, page = 1, id = nil
    result = fetch(count, page, id)
    if result['total'].to_i != self.total or not self.pages
      self.total = result['total'].to_i
      self.pages = (self.total/Export::DEFAULT_MAX_COUNT.to_f).ceil
    end
    result
  end
  
  def fetch_export count, page = 1, id = nil
    if page == 1
      fetch_and_update(count, page, id)
    else
      fetch(count, page, id)
    end
  rescue Desk::TooManyRequests
    # sleep 5 seconds and try again
    sleep(5)
    fetch_export(count, page, id)
  end
  
  class << self    
    def run(id)
      Rails.logger.info("Starting export with ID: #{id}")
      export = find(id)
      Rails.logger.info("Set :is_exporting to true")
      export.update_attribute(:is_exporting, true)
      Rails.logger.info("Starting the export.")
      export.export
      Rails.logger.info("Updated :is_exporting to false and :is_exported to true")
      export.update_attributes(is_exporting: false, is_exported: true)
    end
    
    def tabular_value(value, use_id = true, date_format = :iso)
      if value.is_a?(Array)
        value.map{ |i|
          self.tabular_value(i, use_id, date_format)
        }.join(';')
      elsif value.is_a? Hash
        if use_id
          return value['email']['id'] if value.key?('email')
          return value['twitter']['id'] if value.key?('twitter')
          return value['id'] if value.key?('id')
        else
          return value['email']['email'] if value.key?('email')
          return value['twitter']['login'] if value.key?('twitter')
          return value['name'] if value.key?('name')
        end
      else
        return (DateTime.strptime(value, "%Y-%m-%dT%H:%M:%S%z").to_s(date_format) rescue value)
      end
    end
  end
end
