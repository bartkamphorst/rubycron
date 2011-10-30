describe "RubyCron object" do
  
  require 'RubyCron'
  
  before(:each) do
    @rcj = RubyCron::RubyCronJob.new do |script|
      script.author     = 'John Doe'
      script.name       = 'test'
      script.mailto     = 'john@doe.com'
      script.mailon     = :all
      script.exiton     = :none
      script.verbose    = false
    end
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
  
  after(:each) do
    @rcj = nil
  end
end