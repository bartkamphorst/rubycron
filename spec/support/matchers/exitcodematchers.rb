# Matcher from http://stackoverflow.com/questions/1480537/how-can-i-validate-exits-and-aborts-in-rspec
# Thanks Greg (http://stackoverflow.com/users/384507/greg)

module ExitCodeMatchers
RSpec::Matchers.define :exit_with_code do |code|
    actual = nil
    match do |block|
      begin
        block.call
      rescue SystemExit => e
        actual = e.status
      end
      actual and actual == code
    end
    failure_message_for_should do |block|
      "expected block to call exit(#{code}) but exit" +
        (actual.nil? ? " not called" : "(#{actual}) was called")
    end
    failure_message_for_should_not do |block|
      "expected block not to call exit(#{code})"
    end
    description do
      "expect block to call exit(#{code})"
    end    
  end  
end
