describe "A RubyCronJob" do
  
  before(:each) do
    
    # Using Mail's TestMailer to test delivery
    Mail.defaults do
      delivery_method :test 
    end
    
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
  
    it "loads an ERB template" do
      expect(@rcj.template).to_not be_nil
      expect(::File.basename(@rcj.template)).to eq "report.erb"
      @rcj.template = "my_template.erb"
      expect(::File.basename(@rcj.template)).to eq "my_template.erb"
    end
    
    it "has a Hash of smtp settings" do
      expect(@rcj.smtpsettings).to be_a Hash
    end
  
    it "has proper smtp settings" do
      expect(@rcj.smtpsettings[:address]).to eq "smtp.gmail.com"
      expect(@rcj.smtpsettings[:port]).to eq 587
      expect(@rcj.smtpsettings[:user_name]).to eq "<username>"
      expect(@rcj.smtpsettings[:password]).to eq "<password>"
    end
    
    it "passes mock smtp settings to the Mail gem and terminates" do
      expect(lambda{ 
        @rcj.execute do
          2.times { warning "Filesystem almost full." } 
        end 
      }).to exit_with_code(1)
    end
    
  end
  
  context "with incomplete smtp settings" do
    
    it "exits with code 1 if no address is specified" do
      @smtpsettings.delete(:address)
      @rcjsettings[:smtpsettings] = @smtpsettings
      expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
    end
    
    it "exits with code 1 if no port is specified" do
      @smtpsettings.delete(:port)
      @rcjsettings[:smtpsettings] = @smtpsettings
      expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
    end
      
  end
  
  context "without explicit smtp settings" do
    
    it "exits with code 1 if the default server is not localhost" do
      RubyCron::RubyCronJob.send(:remove_const, :DEFAULT_SERVER)
      expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
      RubyCron::RubyCronJob.send(:const_set, :DEFAULT_SERVER, 'localhost')
    end
  end
  
  after(:each) do
    @rcj = nil
  end
  
end