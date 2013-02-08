OmniAuth.config.on_failure = Proc.new do |env|
  fe = OmniAuth::FailureEndpoint.new(env)
  fe.redirect_to_failure
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :desk, ENV['API_KEY'], ENV['API_SECRET']
  provider :zendesk
end