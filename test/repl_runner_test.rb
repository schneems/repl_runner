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

    ReplRunner.new(:irb, "irb").run do |repl|
      repl.run('111+111')           {|r| assert_match '222', r }
      repl.run("'hello' + 'world'") {|r| assert_match 'helloworld', r }
      repl.run("a = 'foo'")
      repl.run("b = 'bar'")         {} # test empty block doesn't throw exceptions
      repl.run("a * 5")             {|r| assert_match 'foofoofoofoofoo', r }
    end
  end

  def test_forgot_run
    assert_raise RuntimeError do
      ReplRunner.new(:irb, "irb") do |repl|
      end
    end
  end

  def test_does_not_have_trailing_prompts
    ReplRunner.new(:irb, "irb ").run do |repl|
      repl.run('111+111')           {|r| assert_equal "=> 222", r.strip }
    end
  end

  def test_ensure_exit
    assert_raise(ReplRunner::NoResultsError) do
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

  def test_zipping_commands
    commands = "a = 3\nb = 'foo' * a\nputs b"
    zip      = ReplRunner.new(:irb).zip(commands)
    actual   = [["a = 3", "=> 3\r"],
                ["b = 'foo' * a", "=> \"foofoofoo\"\r"],
                ["puts b", "foofoofoo\r\n=> nil\r"]]
    assert_equal actual, zip

    expected = ["a = 3",
                "=> 3\r",
                "b = 'foo' * a",
                "=> \"foofoofoo\"\r",
                "puts b",
                "foofoofoo\r\n=> nil\r"]
    assert_equal expected, zip.flatten
  end
end
