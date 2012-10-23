# Copyright (c) Bart Kamphorst <rubycron@kamphorst.com>, 2011 - 2012.
# Licensed under the modified BSD License. All rights reserved.

module RubyCron

  class RubyCronJob
  
  require 'net/smtp'
  require 'yaml'
  require 'open-uri'
  require 'rubygems'
  require 'mail'
  require 'erb'
  
  attr_accessor :name, :author, :mailto, :mailfrom, :mailsubject, :mailon, :exiton, :template, :smtpsettings, :logfile, :verbose
  attr_reader   :warnings, :errors, :report
  
    def initialize(args = nil)
      @warnings, @errors = [], []
      
      case args
        when NilClass then yield self if block_given?
        when Proc     then instance_eval(args)
        when Hash     then 
          
          args = load_config(:file, args[:configfile]).merge(args) if args[:configfile]
          args = load_config(:url, args[:configurl]).merge(args)   if args[:configurl] 
          
          args.each do |key, value|
            instance_variable_set("@#{key}", value) if value
          end
        else terminate "Expected a hash or a block to initialize, but instead received a #{args.class} object."
      end
            
      check_sanity
      
      rescue => e
        terminate(e.message)
    end
    
    def load_config(source_type, source)
      if source_type == :file
        io = File.open(source) if File.file?(source)
      elsif source_type == :url
        io = open(source)
      end
      yml = YAML::load(io)
      return yml if yml.is_a?(Hash)
      return {}
    end
    
    def check_sanity
      raise "This job has no name."   unless @name 
      raise "This job has no author." unless @author
      raise "No To: header was set. " unless @mailto
      
      check_smtp_settings
      set_defaults
      enable_file_logging if @logfile  
    end
    
    def check_smtp_settings     
      if @smtpsettings
        raise "SMTP settings have to be passed in as a hash." unless @smtpsettings.instance_of?(Hash)
        raise "SMTP settings should include at least an address (:address)." unless @smtpsettings.keys.include?(:address)
        raise "SMTP settings should include at least a port number (:port)." unless @smtpsettings.keys.include?(:port)
      elsif @smtpsettings.nil?
        raise "Cannot connect to local smtp server." unless smtp_connection?
      end
    end
    
    def set_defaults
      @mailfrom       ||= 'root@localhost' 
      @verbose        ||= false 
      @template       ||= File.join(File.dirname(__FILE__), '/report.erb')
      @mailon = :all unless self.mailon && [:none, :warning, :error, :all].include?(self.mailon)
      @exiton = :all unless self.exiton && [:none, :warning, :error, :all].include?(self.exiton)
    end
    
    def enable_file_logging
      $stdout.reopen(@logfile, "a")
      $stdout.sync = true
      $stderr.reopen($stdout)
      rescue => e
        $stdout = STDOUT
        raise e
    end
        
    def terminate(message)
      $stderr.puts "## Cannot complete job. Reason: #{message}" unless ENV['RSPEC']
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
        send_report
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
      return true if ENV['RSPEC']
      return true if Net::SMTP.start('localhost', 25)
      rescue 
        return false
    end
    
    # Report on the status of the cronjob through the use of
    # an erb template file, and mikel's excellent mail gem. 
    private
    def send_report
      @report       = ERB.new(File.read(@template)).result(binding)      
      @mailsubject  = "Cron report for #{name}: #{@warnings.size} warnings & #{@errors.size} errors" unless @mailsubject
      
      mailfrom      = @mailfrom
      mailto        = @mailto
      mailsubject   = @mailsubject
      mailbody      = @report
    
      if @smtpsettings
        smtpsettings = @smtpsettings 
        Mail.defaults do
          delivery_method :smtp, smtpsettings
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