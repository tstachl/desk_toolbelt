require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    begin
      email = Mail::Address.new value
      valid = email.domain && email.address == value
      tree = email.__send__(:tree)
      valid &&= (tree.domain.dot_atom_text.elements.size > 1)
    rescue Exception
      valid = false
    end

    record.errors.add(attr_name, :not_an_email, options) unless valid
  end
end