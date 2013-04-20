require 'json'
require 'nokogiri'
require 'csv'

class String
  def json?
    !!JSON.parse(self)
  rescue
    false
  end
  
  def xml?
    !!Nokogiri::XML(self) { |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
  rescue
    false
  end
  
  def csv?
    !!CSV.parse(self)
  rescue
    false
  end
  
  def sanitize
    self.gsub(/[^a-z0-9\-_]+/i, ' ').strip.gsub(/\s\s+/, ' ').gsub(/ /, '-').downcase
  end
end