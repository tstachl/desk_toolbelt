Desk.configure do |config|
  config.support_email = "thomas@stachl.me"
  config.consumer_key =  ENV['API_KEY']
  config.consumer_secret = ENV['API_SECRET']
  config.use_max_requests = true
  config.max_requests = 10
end