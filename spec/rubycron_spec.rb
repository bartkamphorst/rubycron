describe "RubyCron object" do
  
  require 'RubyCron'
  
  before(:each) do
    @rcj = RubyCron::RubyCronJob.new( 
      :author     => 'John Doe',
      :name       => 'test',
      :mailto     => 'john@doe.com',
      :mailon     => :all,
      :exiton     => :none,
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
  
  it "should initialize with a block for backward compatibility" do
    @rcj = RubyCron::RubyCronJob.new do |script| 
      script.author     = 'Jane Doe'
      script.name       = 'testing blocks'
      script.mailto     = 'jane@doe.com'
      script.mailon     = :all
      script.exiton     = :none
      script.verbose    = false 
    end
    
    @rcj.author.should  == 'Jane Doe'
    @rcj.name.should    == 'testing blocks'
    @rcj.mailto.should  == 'jane@doe.com'
  end
  
  it "should initialize with a yaml hash from file" do
    @rcj = RubyCron::RubyCronJob.new(:configfile => "spec/example.yml")
    @rcj.author.should  == 'Joey Doe'
    @rcj.name.should    == 'config_file_test'
    @rcj.mailto.should  == 'joey@doe.com'
  end
    
  it "should initialize with a yaml hash from a url" do
    @rcj = RubyCron::RubyCronJob.new(:configurl => "spec/example.yml")
    @rcj.author.should  == 'Joey Doe'
    @rcj.name.should    == 'config_file_test'
    @rcj.mailto.should  == 'joey@doe.com'
  end
    
  it "should initialize with mixed configuration sources" do
    @rcj = RubyCron::RubyCronJob.new( :configfile => "spec/example.yml",
                                      :author => "Jet Doe",
                                      :mailto => "jet@doe.com")
    @rcj.author.should  == 'Jet Doe'
    @rcj.name.should    == 'config_file_test'
    @rcj.mailto.should  == 'jet@doe.com'
  end
  
  it "should have an execute method" do
    @rcj.respond_to?(:execute)
  end
  
  after(:each) do
    @rcj = nil
  end
end