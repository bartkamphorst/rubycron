# Copyright (c) Bart Kamphorst <rubycron@kamphorst.com>, 2011
# Licensed under the modified BSD License. All rights reserved.

module RubyCron

  class RubyCronJob
  
  require 'net/smtp'
  require 'rubygems'
  require 'mail'
  require 'erb'
  
  attr_accessor :name, :author, :mailto, :mailfrom, :mailsubject, :mailon, :exiton, :smtp_settings, :logfile, :verbose
  attr_reader   :warnings, :errors
  
    def initialize(&block)
      @warnings, @errors = [], []

      instance_eval(&block)
      if smtp_settings
        terminate("SMTP settings have to be passed in as a hash.") unless smtp_settings.instance_of?(Hash)
        terminate("SMTP settings should include at least an address (:address).") unless smtp_settings.keys.include?(:address)
        terminate("SMTP settings should include at least a port number (:port).") unless smtp_settings.keys.include?(:port)
      else
        terminate("Cannot connect to local smtp server.") unless smtp_connection?
      end
      terminate("This job has no name.") unless self.name 
      terminate("This job has no author.") unless self.author
      terminate("No To: header was set. ") unless self.mailto
      
      self.mailfrom       ||= 'root@localhost' 
      self.verbose        ||= false 
      self.mailon = :all unless self.mailon && [:none, :warning, :error, :all].include?(self.mailon)
      self.exiton = :all unless self.exiton && [:none, :warning, :error, :all].include?(self.exiton)

      if self.logfile
        $stdout.reopen(self.logfile, "a")
        $stdout.sync = true
        $stderr.reopen($stdout)
      end
      rescue => e
        $stdout = STDOUT
        terminate(e.message)
    end
    
    def terminate(message)
      $stderr.puts "## Cannot complete job. Reason: #{message}"
      exit 1
    end
    
    # Execute a given block of code (the cronjob), rescue encountered errors, 
    # and send a report about it if necessary.
    def execute(&block)
      @starttime = Time.now
      puts "\nStarting run of #{self.name} at #{@starttime}.\n----"  if self.verbose || self.logfile
      instance_eval(&block)
    rescue Exception => e
      @errors << e.message
      terminate(e.message) if exiton == (:error || :all)
    ensure
      @endtime = Time.now
      if self.verbose || self.logfile
        puts "Run ended at #{@endtime}.\n----"  
        puts "Number of warnings: #{@warnings.size}" 
        puts "Number of errors  : #{@errors.size}" 
      end
      unless self.mailon == :none || (@warnings.empty? && @errors.empty? && self.mailon != :all)
        report
      end 
    end
   
    def warning(message)
     $stderr.puts message if self.verbose || self.logfile
     raise "Configured to exit on warning." if exiton == (:warning || :all)
     @warnings << message
    end

    def error(message)
      $stderr.puts message if self.verbose || self.logfile
      raise "Configured to exit on error." if exiton == (:error || :all) 
      @errors << message
    end
    
    private 
    def smtp_connection?
      return true if Net::SMTP.start('localhost', 25)
      rescue 
        return false
    end
    
    # Report on the status of the cronjob through the use of
    # an erb template file, and mikel's excellent mail gem. 
    private
    def report
      self.mailsubject = "Cron report for #{name}: #{@warnings.size} warnings & #{@errors.size} errors" unless self.mailsubject
      mailfrom = self.mailfrom
      mailto = self.mailto
      mailsubject = self.mailsubject
      mailbody = ERB.new(File.read(File.join(File.dirname(__FILE__), '/report.erb'))).result(binding)
    
      if smtp_settings 
        Mail.defaults do
          delivery_method :smtp, smtp_settings
        end
      end
      
      mail = Mail.new do
        from    mailfrom
        to      mailto
        subject mailsubject
        body    mailbody
      end

      mail.deliver!
      rescue => e
        terminate(e.message)      
    end  
  end
end