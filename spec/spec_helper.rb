ENV['RSPEC'] = "true"

require 'mail'
# Using Mail's TestMailer to test delivery
Mail.defaults do
  delivery_method :test 
end

# Require custom RSpec matchers
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}

