# stdlib
require 'timeout'
require 'pty'

# gems
require 'active_support/core_ext/object/blank'

class ReplRunner
  attr_accessor :command, :repl

  class NoResultsError < StandardError
    def initialize(command, regex, string)
      msg =  "No result found for command: #{command.inspect}\nIn output: \n  #{string.inspect}\n"
      msg << "Using regex: \n  /#{regex}/\n"
      super(msg)
    end
  end

  class UnregisteredCommand < StandardError
    def initialize(cmd_type)
      msg = "Cannot find registered command type: #{cmd_type.inspect}"
      super(msg)
    end
  end

  def initialize(cmd_type, command = nil, options = {})
    raise "Unexpected block, use the `run` command instead?" if block_given?
    command  = cmd_type.to_s if command.nil?
    cmd_type = cmd_type.chomp.gsub(/\s/, '_').to_sym if cmd_type.is_a?(String)
    @command = command
    @repl    = nil
    @config  = known_configs[cmd_type]
    raise UnregisteredCommand.new(cmd_type) unless @config
    @options = options
  end

  def known_configs
    self.class.known_configs
  end

  class << self
    def known_configs
      @known_configs ||= {}
    end

    def register_command(*commands, &block)
      config = Config.new(commands)
      commands.each do |command|
        known_configs[command] = config
      end
      yield config
    end
    alias :register_commands :register_command
  end

  def start
    @repl = MultiRepl.new(command, @config.to_options.merge(@options))
  end

  def close
    repl.close
  end

  def zip(string)
    results = []
    lines   = string.lines.map(&:rstrip)
    self.run do |repl|
      lines.each do |line|
        repl.run(line) {|result| results << result }
      end
    end
    lines.zip(results)
  end

  def run(&block)
    repl = start
    yield repl
    repl.execute
  ensure
    close if repl
  end
end

require 'repl_runner/pty_party'
require 'repl_runner/multi_command_parser'
require 'repl_runner/multi_repl'
require 'repl_runner/config'
require 'repl_runner/default_config'
