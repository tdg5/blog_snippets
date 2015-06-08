![Pry Plugins](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/08104046/pry_plugins.jpg)

When I was first introduced to the [pry](https://rubygems.org/gems/pry) gem
and the alternative Ruby
[CLI](https://en.wikipedia.org/wiki/Command-line_interface) /
[REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
experience it provides, I have to admit, I didn't get it. I didn't understand
why `pry` was a better option than
[irb](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell) or more typically
for me, `rails console`. Sure, Pry's built-in commands like `ls` make for a
nicer CLI experience, but one could already get similar information by
evaluating a snippet along the lines of `target.methods.sort - Object.methods`,
and what's not nice about typing that 10x a day?

Luckily for you and I (but not my love of typing `Object.methods`), shortly
after my introduction to Pry, I switched jobs and found myself in a dev
environment where `pry` (via [`pry-rails`](https://github.com/rweng/pry-rails))
was the de facto `rails console` replacement and thanks in large part to its
debugging story and the power of `binding.pry`, I've never looked back.

As it turns out, in retrospect, I think my initial roll-of-the-eyes was not in
response to Pry but to the co-worker who introduced me to it; every objection
I had with Pry really boiled down to me asking, "Dude, why must everything be
shiny with you?" Digression aside, the moral of the story is that Pry is a
powerful irb alternative architected for extension.

To that end, in this article, we'll look at the basics of creating a Pry
plugin, from what constitutes a plugin and why you might want to create one, to
the various hooks and other means Pry provides for plugin integration. To do
this, we'll be creating a Pry plugin that customizes Pry with a custom
greeting and can also be used as a sandbox for your future Pry endeavors.

First though, a little bit about Pry! This article assumes you have some
familiarity with Pry, but if this isn't the case, never fear, I'll cover some
resources for getting started with Pry next.

## What is Pry?

For those unfamiliar with Pry, Pry bills itself as

> A powerful alternative to the standard irb shell for Ruby

Written from scratch with advanced functionality in mind, if IRB was [Star
Trek: The Next Generation's Commander
Riker](https://en.wikipedia.org/wiki/William_Riker), Pry would be Riker, after
the beard.

![Commander William T. Riker](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/04124355/riker.jpg)

The full beardth, rather, breadth of the awesomeness of Pry is too much to
go into in this article, but the team behind Pry has done a great job of
covering most of what one might want to know over at
[pryrepl.org](http://pryrepl.org/).

At a glance, some of the advantages of Pry are:

- Source code browsing (including core C source with the pry-doc gem)
- Navigation around state (cd, ls and friends)
- Documentation browsing
- Live help system
- Syntax highlighting
- Command shell integration (start editors, run git, and rake from within Pry)
- Runtime invocation (use Pry as a developer console or debugger)
- A powerful and flexible command system
- Ability to view and replay history
- Many convenience commands inspired by IPython, Smalltalk and other advanced
  REPLs

If a bulleted list isn't enough to convince you, consider also that Pry is
enormously extensible with an ecosystem of fun and powerful plugins contributed
and maintained by the Pry community.

There's really no substitute for spending a few minutes playing around in a Pry
shell to explore the conveniences and utility it offers, so if you haven't
gotten hands-on with Pry, I would definitely recommend doing so.

At this point, I'm going to assume you're sold on Pry (if you weren't already),
and move on to the focus of this article, Pry plugins.

### What is a Pry plugin, anyway?

So that we're all starting on the same page, let's begin by defining what
constitutes a Pry plugin:

> A Pry plugin is a gem or library designed to integrate with and extend Pry
> either by augmenting Pry with new commands and/or by hooking into Pry's
> [read-eval-print loop](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
> to add new behavior.

Whew, what a mouthful! And what does it mean? Let's break it down.

From a certain point of view, this definition is made up of two parts. One part
describing what a Pry plugin is:

> A Pry plugin is a gem or library designed to integrate with and extend Pry

And one part describing what a Pry plugin does:

> A Pry plugin ... [extends] Pry either by augmenting Pry with new commands
> and/or by hooking into Pry's read-eval-print loop to add new behavior.

As you may have picked up on already, in Pry terms, **commands** are the various
special commands built into Pry like `ls` or `whereami` that don't evaluate as
Ruby code, but instead enhance the shell experience in some way. **Going beyond
the built-in commands, many Pry plugins extend Pry with new commands.**

But not all Pry plugins add commands, instead, some plugins change the behavior
of Pry's cycle of reading an input, evaluating that input, and outputting the
result of that evaluation. Some Pry plugins even add new commands **and** hook
into the Pry read-eval-print loop!

Now that we've covered some background on what a Pry plugin is, let's see if we
can find examples of these behaviors in plugins out there in the wild.

#### Pry's wild world of plugins

Pry plugins typically fall into one of a few common categories based on the type of
functionality they provide:

- Debugging tools
  - [pry-byebug](https://github.com/deivid-rodriguez/pry-byebug)
  - [pry-debugger](https://github.com/nixme/pry-debugger)
  - [pry-remote](https://github.com/mon-ouie/pry-remote)
- Command-line interface (CLI) / Command shell
  - [pry-rails](https://github.com/rweng/pry-rails)
  - [pry-macro](https://github.com/baweaver/pry-macro)
- Tweaks and enhancements to pry itself
  - [pry-coolline](https://github.com/pry/pry-coolline)
  - [pry-theme](https://github.com/kyrylo/pry-theme)

These are just a few of the available plugins and even more can be found at
[Pry - Available Plugins](https://github.com/pry/pry/wiki/Available-plugins).

The plugins within each category, depending on the functionality provided,
typically integrate with Pry in a similar fashion. For example, `pry-rails` and
`pry-macro` both integrate with Pry by adding new commands to the Pry shell.
Alternatively, `pry-coolline` and `pry-theme` both add commands **and** hook
into the REPL to change the formating of the given input or output.

Finally, tending toward other extremes, Pry's family of debugging tools
integrate with Pry by whatever means necessary to provide the advertised
functionality. For example, `pry-debugger` and `pry-byebug` (a fork of
`pry-debugger`) both intercept calls to `Pry.start` to inject their behavior.
Taking an alternate approach, `pry-remote` adds an entirely different interface
for starting a Pry session, `Object#remote_pry`, that encapsulates the logic to
transform a Pry breakpoint into a fully functional [Distributed Ruby
(DRb)](https://en.wikibooks.org/wiki/Ruby_Programming/Standard_Library/DRb)
server, ready for a remote client to connect.

Seeing as the Ruby language facilitates just about any kind of advanced Pry
integration one might want to monkeypatch in, we won't discuss more advanced
means of integrating with Pry. Instead, we'll focus on the facilities built
into Pry specifically for plugin integration.

## Integrating with Pry

As we've uncovered so far, there are two primary mechanisms for Pry plugins to
integrate with Pry: either by adding commands to the Pry shell and/or by
registering callbacks into the read-eval-print loop. Seeing as everyone should
be fairly familiar with what a Pry command is, we begin there.

### Commands and the pry command system

Adding new commands to Pry can be one of the easiest ways to add new
functionality to Pry. Pry takes great pride in its command system as one of the
things that sets Pry apart from other REPLs. The trick up Pry's sleeve is that
Pry commands aren't methods like they might seem. Rather, they are special
strings that are caught by Pry before the input buffer is evaluated. This
approach has a number of advantages:

- Commands can do things that methods cannot do, such as modifying the input
  buffer.
- Commands can support a much richer argument syntax than normal methods.
- Commands can be invoked in any context since they are local to the Pry
  session. This avoids monkeypatching and/or extending base classes to make
  commands available in any context.

Since Pry commands are themselves implemented in Ruby, there's really an
endless array of ways commands can be used to extend and customize Pry.

### Adding new commands

New commands can be added to the Pry command shell in a variety of ways.

**Import a command set from code:**

```ruby
Pry.commands.import(PryMacro::Commands)
```

**Import a command set into the current Pry session from REPL:**

```ruby
import-set PryMacro::Commands
```

**Add a command to the current Pry instance's command set:**

```ruby
Pry::Commands.add_command(PryTheme::Command::PryTheme)`
```

```ruby
Pry.commands.add_command(PryByebug::NextCommand)`
```

**Create a command directly on the REPLs default command set:**

```ruby
Pry.commands.block_command("hello", "Say hello to three people") do |x, y, z|
  output.puts "hello there #{x}, #{y}, and #{z}!"
end
```

Though there are a couple of different variations on how it is achieved, each of
the above examples adds commands to the Pry session's default `Pry::CommandSet`.
A command set is Pry's mechanism for organizing groups of commands. The default
command set is automatically generated with Pry's built-in commands and can be
accessed via `Pry.commands` or `Pry::Commands`. As the previous examples
demonstrated, whether to import a whole command set into the default command set
via the `import` method, or to add just a single command via the `add_command `
method, the default command set is a frequent target of Pry plugins.

### Hooks

## Let's make something!

### my_pry

#### command to set greeting

#### Hook to display greeting

# Afterthoughts

## Testing

## Next Steps

- [Pry Plugin Proposals](https://github.com/pry/pry/wiki/Plugin-Proposals)

## Resources

- [Pry - An IRB alternative and runtime developer console](http://pryrepl.org/)
- [pry/pry - GitHub](https://github.com/pry/pry)
- [Pry - Available Plugins](https://github.com/pry/pry/wiki/Available-plugins)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)
