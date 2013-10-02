require 'test_helper'

class MultiCommandParserTest < Test::Unit::TestCase
  def test_removes_command_from_string
    hash = {commands: ["1+1", "'hello' + 'world'"],
            string:   "1+1\r\n => 2 \r\n'hello' + 'world'\r\n => \"helloworld\" \r\n",
            expect:   [" => 2 \r", " => \"helloworld\" \r"]
            }
    cp = ReplRunner::MultiCommandParser.new(hash[:commands])
    assert_equal hash[:expect], cp.parse(hash[:string])
  end

  def test_removes_trailing_prompt
    string = "1+1\r\n => 2 \r\n>"
    regex  = ReplRunner::MultiCommandParser::STRIP_TRAILING_PROMPT_REGEX
    expect = "1+1\r\n => 2"
    before, match, after = string.rpartition(regex)
    assert_equal "1+1\r\n => 2 \r", before
    assert_equal "\n", match
    assert_equal ">", after
  end
end
