class ReplRunner
  class Config
    attr_accessor :commands

    def initialize(*commands)
      @commands = commands
    end

    def terminate_command(command)
      @terminate_command = command
    end

    def startup_timeout(command)
      @startup_timeout = command
    end

    def return_char(char)
      @return_char = char
    end

    def sync_stdout(string)
      @sync_stdout = string
    end

    def to_options
      {
        terminate_command:  @terminate_command,
        startup_timeout:    @startup_timeout,
        return_char:        @return_char,
        sync_stdout:        @sync_stdout
      }
    end
  end
end
