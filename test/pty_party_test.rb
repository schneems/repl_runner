require 'test_helper'

class StreamExecTest < Test::Unit::TestCase
  def test_local_irb_stream
    repl  = ReplRunner::PtyParty.new("irb --simple-prompt")
    repl.run("STDOUT.sync = true\n")
    assert_equal "1+1\r\n=> 2\r\n", repl.run("1+1\n")
    assert_equal "'hello' + 'world'\r\n=> \"helloworld\"\r\n", repl.run("'hello' + 'world'\n")
  end

  def test_multi_command_read
    repl  = ReplRunner::PtyParty.new("irb --simple-prompt")
    repl.write("STDOUT.sync = true\n")
    repl.write("1+1\n")
    repl.write("exit\n")
    result = repl.read
    [
      "STDOUT.sync = true",
      "1+1",
      "exit",
      ">> STDOUT.sync = true",
      "=> true",
      ">> 1+1",
      "=> 2",
      ">> exit"
    ].each do |expected|
      assert_match /#{Regexp.escape(expected)}/, result
    end
  end
end
