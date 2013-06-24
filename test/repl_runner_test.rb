require 'test_helper'

class ReplRunnerTest < Test::Unit::TestCase
  def test_local_irb_stream
    ReplRunner.new(:irb).run do |repl|
      repl.run('111+111')           {|r| assert_match '222', r }
      repl.run("'hello' + 'world'") {|r| assert_match 'helloworld', r }
      repl.run("a = 'foo'")
      repl.run("b = 'bar'")         {} # test empty block doesn't throw exceptions
      repl.run("a * 5")             {|r| assert_match 'foofoofoofoofoo', r }
    end
  end

  def test_ensure_exit
    assert_raise(ReplRunner::NoResults) do
      ReplRunner.new(:irb, "irb -r ./test/require/never-boots.rb", startup_timeout: 2).run do |repl|
        repl.run('111+111') {|r| }
      end
    end
  end

  def test_bash
    ReplRunner.new(:bash).run do |repl|
      repl.run('ls') {|r| assert_match /Gemfile/, r}
    end
  end

  def test_unknown_command
    assert_raise ReplRunner::UnregisteredCommand do
      ReplRunner.new(:zootsuite)
    end
  end

  def test_heroku
    # ReplRunner.new('rails console', "heroku run rails console -a test-app-1372231309-0734751").run do |repl|
    #   repl.run("'foo' * 5")          {|r| assert_match /foofoofoofoofoo/, r }
    #   repl.run("'hello ' + 'world'") {|r| assert_match /hello world/, r }
    # end
  end
end
