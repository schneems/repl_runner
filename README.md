# REPL Runner

Drive irb, bash, or another REPL like environment programmatically.

## Why?

I needed to be able to run `rails console` commands programmatically for testing buildpacks with [Hatchet](http://github.com/heroku/hatchet).

## How?

Ruby includes the PTY library for creating and running [pseudo terminals](http://en.wikipediaorg/wiki/Pseudo_terminal). Unfortunately opening up a remote `irb` or `rails console` session and driving it without deadlocking your process is fairly maddeningly difficult. This library provides a safe abstraction for running commands and parsing the inputs from the outputs.

## Shouldn't this be Called TerminalRunner?

Well technically it should be called Pseudo Terminal Runner, but ReplRunner just has a certain ring to it.

## Install

In your gemfile add:

```
gem 'repl_runner'
```

Then run `$ bundle install`.

## Use

To open a remote rails console on heroku with the heroku toolbelt installed, you could drive it like this:

```ruby
ReplRunner.new(:rails_console, "heroku run rails console -a testapp").run do |repl|
  repl.run('a = 1 + 1')         {|result| assert_match '2', result }
  repl.run('"hello" + "world"') {|result| assert_match 'helloworld', result }
  repl.run("a * 'foo'")         {|result| assert_match 'foofoo', result}
end
```

**Note:** do not forget to call `run` on the ReplRunner object.

The first argument `:rails_console` tells ReplReader what type of a session we are going to open up. The second `"heroku run rails console -a testapp"` is the command we want to use to start our psuedo remote terminal.

You can then call `run` on this and pass in a block. The block yields to a `MultiRepl` instance that can take the command `run` along with arguments to pass into the command line such as `'1+1'`

All outputs will be strings. Commands wait for all commands to finish before returning anything, this is why you supply the `run` command with a block. When the command is done the block will be executed and the result of the command passed to it. This helps us parse the results much more effectively. If you need an immediate return, it's possible but I wouldn't recommend it. As a result I've left that functionality out for now.

Also note that you will get the entire return including any prompts if you run an `irb` session locally with `.9.3` you might see a result like this:

```
$ irb
1.9.3p392 :001 > 1 + 1
=> 2
```

So when you run this via ReplRunner you will get a result string like this

```ruby
ReplRunner.new(:irb).run do |repl|
  repl.run('1 + 1') {|result| puts result }
end
" => 2\r\r\n"
```

Note: if you don't pass in a second parameter i.e. only pass in `:irb` that exact command will be used to start your session.

## Configure

By default ReplRunner knows how to run `:rails_console`, `:bash`, and `:irb`. You can over-write existing defaults by re-defining them. You can register more custom commands you want like this:

```ruby
ReplRunner.register_commands(:rails_console, :irb)  do |config|
  config.terminate_command "exit"          # the command you use to end the 'rails console'
  config.startup_timeout 60                # seconds to boot
  config.return_char "\n"                  # the character that submits the command
  config.sync_stdout "STDOUT.sync = true"  # force REPL to not buffer standard out
end
```

## License

MIT (The Georgia Tech of the North) License. Do whatever you want with this code: I'm not liable or responsible for anything.

