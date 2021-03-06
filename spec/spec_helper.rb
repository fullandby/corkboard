# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'ffaker'
require 'mock_redis'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("../support/**/*.rb")].each {|f| require f}

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Capybara.javascript_driver = (ENV['CAPYBARA_JS'] || :webkit).intern

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
  config.include Support::ConfigHelpers
  config.include Support::ControllerHelpers
  config.include Support::PostHelpers

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

  config.before(:suite) do
    Corkboard.publisher(:mock)
  end

  config.before(:each, :type => :controller) { @routes = Corkboard::Engine.routes }
  config.before(:each, :type => :routing)    { @routes = Corkboard::Engine.routes }
  config.before(:each) do
    Corkboard.redis = MockRedis.new
  end
end
