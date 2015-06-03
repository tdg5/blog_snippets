# Building your first Pry plugin
## What is Pry?
## What is a Pry plugin?
### Kinds of plugins
### Plugin uses
## Integrating with Pry
### Commands
### Hooks
## Let's make something!
### my_pry
#### command to set greeting
#### Hook to display greeting

# Afterthoughts
## Testing
## Resources
## Next Steps

# Building your first Pry plugin

## What is Pry?
  - REPL (Read-Evaluate-Print Loop)

## What is a Pry plugin?

### Kinds of plugins

  - https://github.com/pry/pry/wiki/Available-plugins

#### Commands
  > As Commands are implemented in Ruby, there's an endless number of things that
  > they can be used to do. At the extreme end of the spectrum, the pry_nav plugin
  > adds "step", and "next" commands for walking through Ruby code. A more simple
  > example is provided by the pry-highlight plugin, which adds a single "highlight"
  > command to pretty-print JSON and XML.

  - import-set

### Plugin uses
  - debugging dev ([pry-byebug](https://github.com/deivid-rodriguez/pry-byebug))
  - debugging prod ([pry-remote](https://github.com/mon-ouie/pry-remote))
  - CLI ([pry-rails](https://github.com/rweng/pry-rails))
  - Pry tweaks ([pry-coolline](https://github.com/pry/pry-coolline))

## Let's make something!
  - a home for your own custom commands
    - with greeting!
    - set-greeting
    - greet

  - Start with a gem
  - need pry- name
  - integrate as appropriate

## Hooks
> $ pry
> when_started
> before_whereami, --quiet
> after_whereami, --quiet
> before_session
> [1] pry(main)> binding.pry
> after_read
> before_eval
> when_started
> before_whereami, --quiet
> after_whereami, --quiet
> before_session
> [1] pry(main)> whereami dude
> before_whereami, dude
> At the top level.
> after_whereami, dude
> after_read
> before_eval
> after_eval
> [2] pry(main)> exit
> after_session
> after_eval
> => nil
> [2] pry(main)> exit
> after_session

after_read:
> This hook is supposed to be executed after each line of ruby code
> has been read (regardless of whether eval_string is yet a complete expression)

before_eval:
> Before Ruby code is evaluated

after_eval:
> After Ruby code has been evaluated

when_started
> Fired when a new pry instance is instantiated

before_session
> Fired whenever a new pry session begins

after_session
> Fired at the end of a pry session

before_command(command_name)
> Fires before the named command

after_command(command_name)
> Fires after the named command

## Custom Command resources
  - https://github.com/pry/pry/wiki/Command-system
  - https://github.com/pry/pry/wiki/Custom-commands

## Testing your plugin
  - Two styles of testing
    - From the command's perspective
    - Pry E2E

## Next steps
  - https://github.com/pry/pry/wiki/Plugin-Proposals

Use blog post as place to point people for what there's not time for.

Repeat questions
Ask folks to ask me to slow down if I switch to podcast speed
