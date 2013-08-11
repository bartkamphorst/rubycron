ENV['RSPEC'] = "true"

require 'simplecov'

SimpleCov.start do
  add_filter "/support/"
end

require 'rubycron'

# Monkeypatch to bypass the check for a 
# local smtp server.
class Net::SMTP
  def self.start(server, port)
    raise Net::OpenTimeout if server.nil?
    return true
  end
end

# Require custom RSpec matchers
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}

