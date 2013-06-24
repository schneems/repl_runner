require 'test_helper'

class MultiReplTest < Test::Unit::TestCase
  def test_local_irb_stream
    repl = ReplRunner::MultiRepl.new('irb', terminate_command: 'exit')
    repl.run('111+111')           {|r| assert_match '222', r }
    repl.run("'hello' + 'world'") {|r| assert_match 'helloworld', r }
    repl.run("a = 'foo'")
    repl.run("b = 'bar'")         {} # test empty block doesn't throw exceptions
    repl.run("a * 5")             {|r| assert_match 'foofoofoofoofoo', r }
    repl.execute
  end
end
