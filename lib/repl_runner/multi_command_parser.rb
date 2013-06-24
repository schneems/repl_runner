class ReplRunner
  class MultiCommandParser
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
        regex  = command_to_regex(command)
        result_array = string.split(regex)
        @parsed_result << result_array.pop
        raise NoResults.new(command, raw) if @parsed_result.last.blank?
        string = result_array.join('')
      end

      @parsed_result.reverse!
      return @parsed_result
    end
  end
end
