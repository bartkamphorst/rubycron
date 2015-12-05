describe "A RubyCronJob" do

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
      
      it "has an author" do
        expect(@rcj.author).to eq 'John Doe'
      end
  
      it "has a name" do
        expect(@rcj.name).to eq 'test'
      end
  
      it "has a mailto address" do
        expect(@rcj.mailto).to eq 'john@doe.com'
      end
  
      it "has a mailfrom address" do
        expect(@rcj.mailfrom).to eq 'root@localhost'
      end
    
      it "has an execute method" do
        expect(@rcj).to respond_to(:execute)
      end
      
      context "performing tasks" do
        
        it "succeeds" do
          @rcj.execute do
            10.times { 22 + 20 }
          end
          expect(@rcj.warnings).to be_empty
          expect(@rcj.errors).to be_empty
        end
        
        it "counts warnings" do 
          @rcj.execute do
            5.times { warning "It's not serious, but see someone about it anyway." }
          end
          expect(@rcj.warnings).to have(5).warnings
          expect(@rcj.errors).to have(0).errors
        end
        
        it "counts errors" do
          @rcj.execute do
            5.times { error "Boom! No point in fixing that." }
          end
          expect(@rcj.warnings).to have(0).warnings
          expect(@rcj.errors).to have(5).errors
        end
        
        it "terminates on uncaught exception but includes the error in the count" do
          @rcj.execute do
            5.times { error "Boom! No point in fixing that." }
            5.times { 42 / 0 }
          end
          expect(@rcj.warnings).to have(0).warnings
          expect(@rcj.errors).to have(6).errors
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
        
        it "produces a report" do
          expect(@rcj.report).to include "There were 5 warnings and 2 errors"
          expect(@rcj.report).to include "Boom Boom"
        end
        
        it "delivers the report by email" do
          expect have_sent_email.from('root@localhost').to('john@doe.com').
          matching_subject(/test/).matching_body(/There were 5 warnings and 2 errors/) 
        end
        
      end     
    end
    
    context "with debug mode enabled" do
      
      before(:each) do
        @rcjsettings[:debug] = true
        @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
      end
      
      it "disables sending mail" do
        expect(@rcj.mailon).to eq :none
      end
      
      it "enables verbose output" do
        expect(@rcj.verbose).to be true
      end
    end
    
    context "with logging enabled" do
      it "redirects stdout and stderr to file" do
        @rcjsettings[:logfile] = '/tmp/rspec-test'
        mock_stdout = double('standard out')
        allow(mock_stdout).to receive(:write) { |args| STDOUT.write(args) }
        mock_stderr = double('standard error')
        allow(mock_stderr).to receive(:write) { |args| STDOUT.write(args) }
        begin
          $stdout, $stderr = mock_stdout, mock_stderr

          expect($stdout).to receive(:reopen).with('/tmp/rspec-test', 'a')
          expect($stdout).to receive(:sync=).with(true).once
          expect($stderr).to receive(:reopen).with($stdout)

          @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
        ensure
          $stdout, $stderr = STDOUT, STDERR 
        end
      end
      
      it "reopens $stdout and $stderr in case of an exception" do
        @rcjsettings[:logfile] = 42
        expect(lambda { RubyCron::RubyCronJob.new(@rcjsettings) }).to raise_error SystemExit
        expect($stdout).to eq STDOUT
        expect($stderr).to eq STDERR
      end
      
    end
    
    context "with verbosity mode enabled" do
      it "sends output to stdout and stderr" do
        @rcjsettings[:verbose] = true
        expect($stderr).to receive(:puts).exactly(1).times.with("[INFO ] Starting RubyCronJob...")
        expect($stderr).to receive(:puts).exactly(2).times.with("[WARN ] Filesystem almost full.")
        expect($stderr).to receive(:puts).exactly(5).times.with("[ERROR] More than 42 processes.")
        @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
        @rcj.execute do
          1.times { info "Starting RubyCronJob..." }
          2.times { warning "Filesystem almost full."}
          5.times { error "More than 42 processes." }
        end
      end
    end
    
    context "missing some required settings" do
      it "exits when no name is specified" do
        @rcjsettings.delete(:name)
        expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
      end
    
      it "exits when no author is specified" do
        @rcjsettings.delete(:author)
        expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
      end
    
      it "exits when no mailto address is specified" do
        @rcjsettings.delete(:mailto)
        expect(lambda{ RubyCron::RubyCronJob.new(@rcjsettings) }).to exit_with_code(1)
      end
    end
    
    context "exiting at the first sign of trouble" do
      
      it "exits at the first warning if so configured" do
        @rcjsettings[:exiton] = :warning
        @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
        expect(lambda{
          @rcj.execute do
            3.times { warning "Filesystem almost full."}
          end
        }).to exit_with_code(1)
        expect(@rcj.warnings).to have(1).warnings
        expect(@rcj.errors).to have(0).errors
      end
      
      it "exits at the first error if so configured" do
        @rcjsettings[:exiton] = :error
        @rcj = RubyCron::RubyCronJob.new(@rcjsettings)
        expect(lambda{
          @rcj.execute do
            2.times { warning "Filesystem almost full."}
            5.times { error "More than 42 processes." }
          end
        }).to exit_with_code(1)
        expect(@rcj.warnings).to have(2).warnings
        expect(@rcj.errors).to have(1).errors
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
    
    it "has an author" do
      expect(@rcj.author).to eq 'Jane Doe'
    end
    
    it "has a name" do
      expect(@rcj.name).to eq 'testing blocks'
    end
    
    it "has a mailto address" do
      expect(@rcj.mailto).to eq 'jane@doe.com'
    end
  end
  
  context "initialized with a Proc" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new(Proc.new { 
          @author     = 'Janet Doe'
          @name       = 'testing procs'
          @mailto     = 'janet@doe.com'
          @mailon     = :all
          @exiton     = :none
          @smtpsettings = false
          @verbose    = false 
      })
    end
      
    it "has an author, a name, and a mailto address" do
      expect(@rcj.author).to eq 'Janet Doe'
      expect(@rcj.name).to eq 'testing procs'
      expect(@rcj.mailto).to eq 'janet@doe.com'
    end
      
  end
  
  context "initialized with a yaml hash from file" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new(:configfile => "spec/support/yaml/example.yml")
    end
    
    it "has an author, a name, and a mailto address" do
      expect(@rcj.author).to eq 'Joey Doe'
      expect(@rcj.name).to eq 'config_file_test'
      expect(@rcj.mailto).to eq 'joey@doe.com'
    end
  end
    
  context "initialized with a yaml hash from a url" do  
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new(:configurl => "spec/support/yaml/example.yml")
    end
    it "has an author, a name, and a mailto address" do
      expect(@rcj.author).to eq 'Joey Doe'
      expect(@rcj.name).to eq 'config_file_test'
      expect(@rcj.mailto).to eq 'joey@doe.com'
    end
  end
    
  context "initialized with mixed configuration sources" do
    before(:each) do
      @rcj = RubyCron::RubyCronJob.new( :configfile => "spec/support/yaml/example.yml",
                                      :author => "Jet Doe",
                                      :mailto => "jet@doe.com")
    end
    
    it "has an author, a name, and a mailto address" do
      expect(@rcj.author).to eq 'Jet Doe'
      expect(@rcj.name).to eq 'config_file_test'
      expect(@rcj.mailto).to eq 'jet@doe.com'
    end
  end
  
  context "initialized incorrectly" do
    context "with a String" do
      it "terminates with code 1" do
        expect(lambda{ @rcj = RubyCron::RubyCronJob.new("One new rcj please.")}).to exit_with_code(1)
      end
    end
    
    context "with incorrect YAML" do
      it "terminates with code 1" do
        expect(lambda{ @rcj = RubyCron::RubyCronJob.new(:configurl => "spec/support/yaml/empty_array.yml")}).to exit_with_code(1)
      end
    end
  end
  
  after(:each) do
    @rcj = nil
  end
end