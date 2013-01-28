Rails.application.config.middleware.use OmniAuth::Builder do
  provider :desk, ENV['API_KEY'], ENV['API_SECRET']
end