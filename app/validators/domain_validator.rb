require 'resolv'

class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    valid = true
    begin
      Resolv::DNS.new.getresource(value, Resolv::DNS::Resource::IN::A)
    rescue Exception
      valid = false
    end

    record.errors.add(attr_name, :not_a_domain, options) unless valid
  end
end