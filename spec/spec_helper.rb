ENV['RSPEC'] = "true"

# Require custom RSpec matchers
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}

