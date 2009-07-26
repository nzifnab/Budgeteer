require 'rubygems'
require 'spork'

ENV["RAILS_ENV"] ||= "cucumber"
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # Sets up the Rails environment for Cucumber
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
  require 'cucumber/rails/world'
  
  # Comment out the next line if you don't want transactions to
  # open/roll back around each scenario
  Cucumber::Rails.use_transactional_fixtures
  
  # Comment out the next line if you want Rails' own error handling
  # (e.g. rescue_action_in_public / rescue_responses / rescue_from)
  Cucumber::Rails.bypass_rescue
  require 'webrat'
  
  Webrat.configure do |config|
    config.mode = :rails
  end
  require 'cucumber/rails/rspec'
  require 'webrat/core/matchers'
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#






# Comment out the next line if you don't want Cucumber Unicode support
#require 'cucumber/formatter/unicode'










