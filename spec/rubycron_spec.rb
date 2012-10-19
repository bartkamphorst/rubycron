describe "RubyCron object" do
  
  require 'RubyCron'
  
  context "initialized with a hash" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new( 
        :author     => 'John Doe',
        :name       => 'test',
        :mailto     => 'john@doe.com',
        :mailon     => :all,
        :exiton     => :none,
        :smtpsettings => false,
        :verbose    => false )
    end
  
    it "should have an author" do
      @rcj.author.should == 'John Doe'
    end
  
    it "should have a name" do
      @rcj.name.should == 'test'
    end
  
    it "should have a mailto address" do
      @rcj.mailto.should == 'john@doe.com'
    end
  
    it "should have a mailfrom address" do
      @rcj.mailfrom.should be
    end
    
    it "should have an execute method" do
      @rcj.should respond_to(:execute)
    end
    
  end
  
  context "initialized with a block" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new do |script| 
        script.author     = 'Jane Doe'
        script.name       = 'testing blocks'
        script.mailto     = 'jane@doe.com'
        script.mailon     = :all
        script.exiton     = :none
        script.smtpsettings = false
        script.verbose    = false 
      end
    end
    
    it "should have an author" do
      @rcj.author.should  == 'Jane Doe'
    end
    
    it "should have a name" do
      @rcj.name.should    == 'testing blocks'
    end
    
    it "should have a mailto address" do
      @rcj.mailto.should  == 'jane@doe.com'
    end

  end
  
  context "initialized with a yaml hash from file" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new(:configfile => "spec/example.yml")
    end
    
    it "should have an author, a name, and a mailto address" do
      @rcj.author.should  == 'Joey Doe'
      @rcj.name.should    == 'config_file_test'
      @rcj.mailto.should  == 'joey@doe.com'
    end
  end
    
  context "initialized with a yaml hash from a url" do  
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new(:configurl => "spec/example.yml")
    end
    it "should have an author, a name, and a mailto address" do
      @rcj.author.should  == 'Joey Doe'
      @rcj.name.should    == 'config_file_test'
      @rcj.mailto.should  == 'joey@doe.com'
    end
  end
    
  context "initialized with mixed configuration sources" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new( :configfile => "spec/example.yml",
                                      :author => "Jet Doe",
                                      :mailto => "jet@doe.com")
    end
    
    it "should have an author, a name, and a mailto address" do
      @rcj.author.should  == 'Jet Doe'
      @rcj.name.should    == 'config_file_test'
      @rcj.mailto.should  == 'jet@doe.com'
    end
  end
  
  after(:each) do
    @rcj = nil
  end
end