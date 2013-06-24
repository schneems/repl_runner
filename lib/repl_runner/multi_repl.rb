class ReplRunner
  # Takes in a command, to start a REPL session with PTY
  # builds up a list of commands we want to run in our REPL
  # executes them all at a time, reads in the result and returns results
  # back to blocks
  class MultiRepl
    class UnexpectedExit < StandardError
    end

    DEFAULT_STARTUP_TIMEOUT = 60
    DEFAULT_RETURN_CHAR     = "\n"

    attr_accessor :command

    def initialize(command, options = {})
      @command_parser    = options[:command_parser]    || MultiCommandParser
      @return_char       = options[:return_char]       || DEFAULT_RETURN_CHAR
      @startup_timeout   = options[:startup_timeout]   || DEFAULT_STARTUP_TIMEOUT
      @terminate_command = options[:terminate_command] or raise "must set default `terminate_command`"
      @stync_stdout      = options[:sync_stdout]

      @command  = command
      @commands = []
      @jobs     = []
    end

    def pty
      @pty ||= PtyParty.new(command)
    end

    def run(command, &block)
      @commands << command
      @jobs     << (block || Proc.new {|result| })
    end

    def write(command)
      pty.write("#{command}#{@return_char}")
    end

    def alive?
      !!::Process.kill(0, pty.pid) rescue false # kill zero will return the status of the proceess without killing it
    end

    def dead?
      !alive?
    end

    def read
      raise UnexpectedExit, "Repl: '#{@command}' exited unexpectedly" if dead?
      @output = pty.read(@startup_timeout)
    end

    def parse_results
      @parsed_results ||= @command_parser.new(@commands, @terminate_command).parse(read)
    end

    def close
      pty.close
    end

    def execute
      write(@sync_stdout) if @sync_stdout

      @commands.each do |command|
        write(command)
      end

      write(@terminate_command)


      output_array = parse_results

      @jobs.each_with_index do |job, index|
        job.call(output_array[index])
      end
    rescue NoResults => e
      raise e, "Booting up REPL with command: #{command.inspect} \n#{e.message}"
    end
  end
end
