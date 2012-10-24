describe "A RubyCronJob" do
  
  before(:each) do
    @smtpsettings = { 	
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => 'your.host.name',
    	:user_name            => '<username>',
    	:password             => '<password>',
    	:authentication       => 'plain',
    	:enable_starttls_auto => true  
    }
    @rcjsettings = {
      :author         => 'John Doe',
      :name           => 'test',
      :mailto         => 'john@doe.com',
      :mailon         => :all,
      :exiton         => :none,
      :verbose        => false,
    }
  end
  
  context "with complete smtp settings" do
    
    before(:each) do
      @rcjsettings[:smtpsettings] = @smtpsettings
      @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
    end
  
    it "should load a ERB template" do
      @rcj.template.should be
      File.basename(@rcj.template).should == "report.erb"
      @rcj.template = "my_template.erb"
      File.basename(@rcj.template).should == "my_template.erb"
    end
    
    it "should have a Hash of smtp settings" do
      @rcj.smtpsettings.should be_a Hash
    end
  
    it "should have proper smtp settings" do
      @rcj.smtpsettings[:address].should   == "smtp.gmail.com"
      @rcj.smtpsettings[:port].should      == 587
      @rcj.smtpsettings[:user_name].should == "<username>"
      @rcj.smtpsettings[:password].should  == "<password>"
    end
  end
  
  context "with incomplete smtp settings" do
    
    it "should exit with code 1 if no address is specified" do
      @smtpsettings.delete(:address)
      @rcjsettings[:smtpsettings] = @smtpsettings
      lambda { RubyCron::RubyCronJob.new(@rcjsettings) }.should exit_with_code(1)
    end
    
    it "should exit with code 1 if no port is specified" do
      @smtpsettings.delete(:port)
      @rcjsettings[:smtpsettings] = @smtpsettings
      lambda { RubyCron::RubyCronJob.new(@rcjsettings) }.should exit_with_code(1)
    end
      
  end
  
  after(:each) do
    @rcj = nil
  end
  
end