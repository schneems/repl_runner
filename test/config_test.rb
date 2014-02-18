require 'test_helper'

class ConfigTest < Test::Unit::TestCase

  def setup
   @hash = {terminate_command: "exitYoSelf",
            startup_timeout:   99,
            return_char:       "poof",
            sync_stdout:       "NSync"}
  end

  def test_config
    config = ReplRunner::Config.new(:irb, :rails_console)
    config.terminate_command @hash[:terminate_command]
    assert_equal @hash[:terminate_command], config.to_options[:terminate_command]

    config.startup_timeout @hash[:startup_timeout]
    assert_equal @hash[:startup_timeout], config.to_options[:startup_timeout]

    config.return_char @hash[:return_char]
    assert_equal @hash[:return_char], config.to_options[:return_char]

    config.sync_stdout @hash[:sync_stdout]
    assert_equal @hash[:sync_stdout], config.to_options[:sync_stdout]

    assert_equal @hash, config.to_options
  end

  def test_default_config
    runner = ReplRunner.new("bin/rails console")
    assert_equal "exit", runner.config.to_options[:terminate_command]
  end
end
