require 'test_helper'

class StreamExecTest < Test::Unit::TestCase
  def test_local_irb_stream
    repl  = ReplRunner::PtyParty.new("irb")
    repl.run("STDOUT.sync = true\n")
    assert_equal "1+1\r\n => 2 \r\n", repl.run("1+1\n")
    assert_equal "'hello' + 'world'\r\n => \"helloworld\" \r\n", repl.run("'hello' + 'world'\n")
  end

  def test_multi_command_read
    repl  = ReplRunner::PtyParty.new("irb")
    repl.write("STDOUT.sync = true\n")
    repl.write("1+1\n")
    repl.write("exit\n")
    assert_equal "STDOUT.sync = true\r\n1+1\r\nexit\r\n2.0.0-p0 :001 > STDOUT.sync = true\r\n => true \r\n2.0.0-p0 :002 > 1+1\r\n => 2 \r\n2.0.0-p0 :003 > exit\r\n", repl.read
  end
end
