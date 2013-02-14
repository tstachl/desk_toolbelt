# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'faker'
require 'webmock/rspec'
require 'omniauth'
require 'omniauth-desk'
require 'omniauth-zendesk'

omniauth_name = Faker::Name.name
omniauth_email = Faker::Internet.email(omniauth_name)

OmniAuth.config.mock_auth[:desk] = OmniAuth::AuthHash.new({
  provider:  'desk',
  uid:       '1234565',
  info: {
    name:         omniauth_name,
    name_public:  omniauth_name,
    email:        omniauth_email,
    user_level:   'siteadmin_billing',
    login_count:  55,
    time_zone:    '',
    site:         'https://devel.desk.com'
  },
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})

OmniAuth.config.mock_auth[:desk_dan] = OmniAuth::AuthHash.new({
  provider:  'desk',
  uid:       '1324565',
  info: {
    name:         omniauth_name,
    name_public:  omniauth_name,
    email:        omniauth_email,
    user_level:   'siteadmin_billing',
    login_count:  55,
    time_zone:    '',
    site:         'https://zzz-dan.desk.com'
  },
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})

OmniAuth.config.mock_auth[:zendesk] = OmniAuth::AuthHash.new({
  provider: 'zendesk',
  uid:      '1234565',
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # declare an exclusion filter
  config.filter_run_excluding broken: true, moved: true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  config.include ModelMacro
  config.include WebMock::API
  config.include FactoryGirl::Syntax::Methods
end
