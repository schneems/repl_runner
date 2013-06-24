require 'test_helper'

class MultiCommandParserTest < Test::Unit::TestCase
  def test_removes_command_from_string
    hash = {commands: ["1+1", "'hello' + 'world'"],
            string:   "1+1\r\n => 2 \r\n'hello' + 'world'\r\n => \"helloworld\" \r\n",
            expect:   [" => 2 \r\n", " => \"helloworld\" \r\n"]
            }
    cp = ReplRunner::MultiCommandParser.new(hash[:commands])
    assert_equal hash[:expect], cp.parse(hash[:string])
  end
end
