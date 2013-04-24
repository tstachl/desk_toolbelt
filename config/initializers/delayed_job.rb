Delayed::Worker.backend = :active_record
if Rails.env.development?
  module Delayed::Backend::Base
    def payload_object_with_reload
      if @payload_object_with_reload.nil?
        ActiveSupport::Dependencies.clear
      end
      @payload_object_with_reload ||= payload_object_without_reload
    end
    alias_method_chain :payload_object, :reload
  end
end