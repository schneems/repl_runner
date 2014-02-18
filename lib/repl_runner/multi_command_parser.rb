class ReplRunner
  class MultiCommandParser
    STRIP_TRAILING_PROMPT_REGEX = /(\r|\n)+/
    attr_accessor :commands, :raw

    def initialize(commands, terminate_command = nil)
      @commands          = commands
      @terminate_command = terminate_command
      @raw               = ""
    end

    def command_to_regex(command)
      /#{Regexp.quote(command)}\r*\n+/
    end

    def parse(string)
      self.raw    = string.dup
      @parsed_result = []

      # remove terminate command
      string = string.gsub(command_to_regex(@terminate_command), '') if @terminate_command
      # attack the string from the end
      commands.reverse.each do |command|
        regex = command_to_regex(command)
        before, match, result = string.rpartition(regex)

        raise NoResultsError.new(command, regex, raw) if result.empty?

        string = before
        @parsed_result << result.rpartition(STRIP_TRAILING_PROMPT_REGEX).first
      end

      @parsed_result.reverse!
      return @parsed_result
    end
  end
end
