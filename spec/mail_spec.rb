describe "cron report" do
  
  require 'RubyCron'
  
  before(:each) do
    
    smtp_settings = { 	
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => 'your.host.name',
    	:user_name            => '<username>',
    	:password             => '<password>',
    	:authentication       => 'plain',
    	:enable_starttls_auto => true  
    }
    
    @rcj = RubyCron::RubyCronJob.new do |script|
      script.author         = 'John Doe'
      script.name           = 'test'
      script.mailto         = 'john@doe.com'
      script.mailon         = :all
      script.exiton         = :none
      script.verbose        = false
      script.smtp_settings  = smtp_settings
    end
  end
  
  it "should load a ERB template" do
    @rcj.template.should be
    File.basename(@rcj.template).should == "report.erb"
  end
  
  after(:each) do
    @rcj = nil
  end
  
end