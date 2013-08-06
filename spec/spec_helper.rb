ENV['RSPEC'] = "true"

require 'simplecov'

SimpleCov.start do
  add_filter "/support/"
end

# require 'RubyCron'
require 'rubycron'

# Monkeypatch to bypass the check for a 
# local smtp server. 
module RubyCron
  class RubyCronJob
    def smtp_connection? ; true ; end
  end
end

require 'mail'
# Using Mail's TestMailer to test delivery
Mail.defaults do
  delivery_method :test 
end

# Require custom RSpec matchers
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}

