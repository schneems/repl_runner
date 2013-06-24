class ReplRunner
  class PtyParty
    attr_accessor :input, :output, :pid
    TIMEOUT = 1

    def initialize(command)
      @output, @input, @pid = PTY.spawn(command)
    end

    def write(cmd)
      input.write(cmd)
    rescue Errno::EIO => e
      raise e, "#{e.message} | trying to write '#{cmd}'"
    end

    def run(cmd, timeout = TIMEOUT)
      write(cmd)
      return read(timeout)
    end

    def close(timeout = TIMEOUT)
      Timeout::timeout(timeout) do
        input.close
        output.close
      end
    rescue Timeout::Error
      # do nothing
    ensure
      Process.kill('TERM', pid)   if pid.present?
    end

    # There be dragons - (You're playing with process deadlock)
    #
    # We want to read the whole output of the command
    # First pull all contents from stdout (except we don't know how many there are)
    # So we have to go until our process deadlocks, then we timeout and return the string
    #
    def read(timeout = TIMEOUT, str = "")
      while true
        Timeout::timeout(timeout) do
          str << output.readline
          break if output.eof?
        end
      end

      return str
    rescue Timeout::Error, EOFError, Errno::EIO
      return str
    end
  end
end
