describe "A RubyCronJob" do
  
  require 'RubyCron'
  
  context "initialized with a hash" do
    before(:each) do
      @rcjsettings = {
        :author     => 'John Doe',
        :name       => 'test',
        :mailto     => 'john@doe.com',
        :mailon     => :all,
        :exiton     => :none,
        :smtpsettings => false,
        :verbose    => false
      }
    end

    context "containing all required settings" do
      before(:each) do
        @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
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
      
      context "performing tasks" do
        
        it "should succeed" do
          @rcj.execute do
            10.times { 22 + 20 }
          end
          @rcj.warnings.should be_empty
          @rcj.errors.should be_empty
        end
        
        it "should count warnings" do 
          @rcj.execute do
            5.times { warning "It's not serious, but see someone about it anyway." }
          end
          @rcj.warnings.should have(5).warnings
          @rcj.errors.should have(0).errors
        end
        
        it "should count errors" do
          @rcj.execute do
            5.times { error "Boom! No point in fixing that." }
          end
          @rcj.warnings.should have(0).warnings
          @rcj.errors.should have(5).errors
        end
        
        it "should terminate at uncaught exception but include the error in the count" do
          @rcj.execute do
            5.times { error "Boom! No point in fixing that." }
            5.times { 42 / 0 }
          end
          @rcj.warnings.should have(0).warnings
          @rcj.errors.should have(6).errors
        end
        
      end
      
      context "reporting the results" do
        include Mail::Matchers
        
        before(:each) do
          Mail::TestMailer.deliveries.clear
          @rcj.execute do
            5.times { warning "Boom Boom" }
            2.times { error "Bang Bang" }
          end
        end
        
        it "should produce a report" do
          @rcj.report.should include "There were 5 warnings and 2 errors"
          @rcj.report.should include "Boom Boom"
        end
        
        it "should deliver the report by email" do
          should have_sent_email.from('root@localhost').to('john@doe.com').
          matching_subject(/test/).matching_body(/There were 5 warnings and 2 errors/) 
        end
        
      end
      
    end
    
    context "missing some required settings" do
      it "should exit when no name is specified" do
        @rcjsettings.delete(:name)
        lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }.should exit_with_code(1)
      end
    
      it "should exit when no author is specified" do
        @rcjsettings.delete(:author)
        lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }.should exit_with_code(1)
      end
    
      it "should exit when no mailto address is specified" do
        @rcjsettings.delete(:mailto)
        lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }.should exit_with_code(1)
      end
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