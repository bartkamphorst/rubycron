# RubyCron

Define your cronjobs in your favorite language, and get reporting for free!

By letting RubyCron deal with warnings, errors, and sending reports, you can focus on writing clean and effective cronjobs in Ruby.

## Author

* Bart Kamphorst

## Installation
	#> gem install rubycron

### Dependencies 

This gem depends on [Mikel's wonderful mail gem](https://github.com/mikel/mail).

In order to send mail, it assumes you have a local smtp server running on port 25.

## Usage

### Configure the basics

Open a new file, require and include RubyCron, and then initialize a new RubyCronJob as follows:

	rcj = RubyCronJob.new do |script|
  		script.author     = 'John Doe'
  		script.name       = 'test'
		script.mailto     = 'john@doe.com'
	end

### Write your cronjob

Call RubyCronJob's execute method, and define your cronjob within the do-end block.

	rcj.execute do 
	  unless File.directory?('/tmp')
	    warning "Something awry is going on with /tmp."
	  end
	  begin
	  File.open('/tmp/rubycrontest', 'w') do |f|
	  	f.write("Test completed successfully.")
	  end
	  rescue => e
	    error "Something went wrong trying to write to file: #{e.message}"
	  end
	end
	
That's it! Now when you run this cronjob, you will receive a report by email.

## Set up Cron

To activate the cronjob, add it to your crontab like any other cronjob. There are, however, two ways to do this: run the RubyCronJob as a stand-alone script, or have the RubyCronJob be executed by rcjrunner.rb.

### Stand-alone

For the stand-alone option, add a crontab entry like so:
	
	min		hour	mday	month	wday	command
	* 		* 		* 		* 		* 		test.rcj

For this to work properly, make sure your rubycronjob (test.rcj in this example) starts with a shebang and is executable.

### Using rcjrunner.rb

Simply feed your rubycronjob to rcjrunner.rb as a command-line argument in your crontab entry:
	
	min		hour	mday	month	wday	command
	* 		* 		* 		* 		* 		rcjrunner.rb test.rcj

## Other configuration options

### I now get all these reports, but I really only care if the job fails! 

Sorting through hundreds of cron mails per day that report successful runs may be gratifying at times, but most sane people only care to be notified when their cronjobs fail. Not to worry, just add to following line to the RubyCronJob's initialization. 

	script.mailon	= :error

RubyCron will now only report when errors occurred during the run. Other options are :none, :warning and :all (default).

### All emails originate from root@localhost. Can I change that?

Of course. Use 

	script.mailfrom   = 'root@doe.com'

to change the From:-header.

### I want my cronjob to stop running when there are errors.

No problem. You can configure this behavior with

	script.exiton	= :all

Valid values are :none, :warning, :error, :all.

### May I please see some output while I'm developing my cronjob?

Output to stdout and stderr can be very useful when debugging your cronjob. Just set the verbose flag to true:

	script.verbose	= true

### As a sysadmin, I like grepping through files. Can I have a log file please?

Yes. Set a file path in RubyCronJob's logfile variable, and all output will be redirected to file:

	script.logfile	= '/tmp/rcjlogfile'

Note that you will still receive email reports when you enable file logging. 

## License

Copyright (c) 2011, Bart Kamphorst

(Modified BSD License)

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of the organization nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.