class Provider::Zendesk < Provider
  SUPPORTED_TYPES_MAP = {
    :case         => :ticket,
    :interaction  => :ticket_audit,
    :customer     => :user,
    :topic        => :forum,
    :article      => :topic
  }

  def markup
    @@markup ||= ({}).tap do |markup|
      SUPPORTED_TYPES.each do |item|
        markup[item] = JSON.parse(File.new("#{Rails.root}/app/models/provider/zendesk/#{SUPPORTED_TYPES_MAP[item].to_s}.json").read)
      end
    end
  end
end