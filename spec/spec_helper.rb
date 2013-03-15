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
require 'vcr'
require 'omniauth'
require 'omniauth-desk'
require 'omniauth-zendesk'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

VCR.configure do |config|
  config.cassette_library_dir     = 'spec/cassettes'
  config.hook_into                :webmock
  config.ignore_localhost         = true
  config.default_cassette_options = { record: :none }
end

RSpec.configure do |config|
  config.backtrace_clean_patterns = [
    /\/lib\d*\/ruby\//,
    /bin\//,
    # /gems/,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
  
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
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  
  config.include ModelMacro
  config.include WebMock::API
  config.include FactoryGirl::Syntax::Methods
  
  # config.before(:all) do
  #   stub_request(:get, /.*globalsurfco.zendesk.com\/api\/v2\/users.*/).
  #           with(headers: {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'ZendeskAPI API 0.2.2'}).
  #      to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/zendesk/users.json'))
  # 
  #   stub_request(:get, /.*devel.desk.com\/api\/v1\/cases.*/).
  #           with(query: hash_including({ count: 1 })).
  #      to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
  # 
  #   stub_request(:get, /.*devel.desk.com\/api\/v1\/cases.*/).
  #           with(query: hash_including({ count: 10 })).
  #      to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases.json'), headers: {content_type: "application/json; charset=utf-8"})
  # 
  #   stub_request(:get, /.*devel.desk.com\/api\/v1\/cases.*/).
  #           with(query: hash_including({ count: 100 })).
  #      to_return(status: 200, body: File.new(Rails.root + 'spec/fixtures/desk/cases_export.json'), headers: {content_type: "application/json; charset=utf-8"})
  # end
end
