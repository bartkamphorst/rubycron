describe "cron report" do
  
  require 'RubyCron'
  
  before(:each) do
    
    smtpsettings = { 	
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => 'your.host.name',
    	:user_name            => '<username>',
    	:password             => '<password>',
    	:authentication       => 'plain',
    	:enable_starttls_auto => true  
    }
    
    @rcj = RubyCron::RubyCronJob.new(
      :author         => 'John Doe',
      :name           => 'test',
      :mailto         => 'john@doe.com',
      :mailon         => :all,
      :exiton         => :none,
      :verbose        => false,
      :smtpsettings   => smtpsettings )
  end
  
  it "should load a ERB template" do
    @rcj.template.should be
    File.basename(@rcj.template).should == "report.erb"
    @rcj.template = "my_template.erb"
    File.basename(@rcj.template).should == "my_template.erb"
  end
  
  it "should have proper smtp settings" do
    @rcj.smtpsettings[:address].should   == "smtp.gmail.com"
    @rcj.smtpsettings[:port].should      == 587
    @rcj.smtpsettings[:user_name].should == "<username>"
    @rcj.smtpsettings[:password].should  == "<password>"
  end
  
  after(:each) do
    @rcj = nil
  end
  
end