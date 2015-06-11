![Pry Plugins](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/08104046/pry_plugins.jpg)

When I was first introduced to the [pry](https://rubygems.org/gems/pry) gem and
the alternative Ruby [CLI](https://en.wikipedia.org/wiki/Command-line_interface)
/ [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
experience it provides, I have to admit, I didn't get it. I didn't understand
why `pry` was a better option than
[irb](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell) or more typically
for me, `rails console`. Sure, Pry's built-in commands like `ls` or `cd` (not to
be confused with their OS shell namesakes) make for a nicer CLI experience, but
one could already get information similar to the `ls` command by evaluating a
snippet along the lines of `target.methods.sort - Object.methods`, and what's
not nice about typing that 10x a day?

Luckily for you and I (but not my love of typing `Object.methods`), shortly
after my introduction to Pry, I switched jobs and found myself in a dev
environment where `pry` (via [`pry-rails`](https://github.com/rweng/pry-rails))
was the de facto `rails console` and thanks in large part to its debugging story
and the power of `binding.pry`, I've never looked back.

To that end, in this article, we'll look at the basics of creating a Pry
plugin, from what constitutes a plugin and why you might want to create one, to
the various hooks and other means Pry provides for plugin integration. To do
this, we'll be creating a Pry plugin that customizes Pry with a custom
greeting and can also be used as a sandbox for your own future Pry endeavors.

First though, a little bit about Pry! This article assumes you have some
familiarity with Pry, but if this isn't the case, never fear, I'll cover some
resources for getting started with Pry next and in the
[Additional Resources](#additional-resources) section.

## What is Pry?

For those unfamiliar with Pry, Pry bills itself as

> A powerful alternative to the standard irb shell for Ruby

Written from scratch with advanced functionality in mind, if IRB was [Star
Trek: The Next Generation's Commander
Riker](https://en.wikipedia.org/wiki/William_Riker), Pry would be Riker, after
the beard. Sure, IRB will get you through your first season, but sooner or later
an away mission comes along and once you see what Pry is capable of it's hard to
go back.

![Commander William T. Riker](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/04124355/riker.jpg)

The full beardth, rather, breadth of the awesomeness of Pry is too much to go
into in this article, but the team behind Pry has done a great job of covering
most of what one might want to know over at [pryrepl.org](http://pryrepl.org/).

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

All that said, there's really no substitute for spending a few minutes playing
around in a Pry shell to explore the conveniences and utility it offers, so if
you haven't gotten hands-on with Pry, I would definitely recommend doing so.

At this point, I'm going to assume you're sold on Pry (if you weren't already),
and move on to the focus of this article, Pry plugins.

### What is a Pry plugin, anyway?

So that we're all starting on the same page, let's begin by defining what
constitutes a Pry plugin. First, here's what the [Pry
wiki](https://github.com/pry/pry/wiki/Plugins#what-is-a-plugin) has to say on
the matter:

> A valid Pry plugin is a gem that has the `pry-` prefix (such as the `pry-doc`
> gem). There must also be a `.rb` file of the same name in the `lib/` folder of
> the gem. The functionality provided by a plugin is typically implemented by
> way of the customization and command system APIs.

I think this definition does a fair job of describing the situation, but I have
two gripes with this definition. First, this definition is out-dated and makes
no reference to the various hooks built into Pry for customizing behavior. More
on that later.

Second, though it is convenient that Pry will automatically load plugins that
have a `pry-` prefix, there is nothing preventing a gem without such a prefix
from plugging into and extending Pry. Maybe it is preferable to default to
allowing all the things to be loaded by Pry automatically and, thus, defer which
plugins are actually loaded to Pry and the `.pryrc` file. But, even if that is
the reasoning behind this nomenclature, it seems excessive to suggest such a
plugin is "invalid", as there is almost certainly a use-case for a Pry plugin
that is not automatically loaded by Pry. Eh, I'm probably being overly semantic.

My complaints registered, I submit the following definition for a Pry plugin:

> A Pry plugin is a gem that integrates with Pry, typically by configuring
> environment behavior through Pry's customization API; altering or extending
> Pry's command system; and/or by registering behavior via Pry's system of
> life-cycle and REPL hooks. Plugins named with a `pry-` prefix (e.g. `pry-doc`)
> and including a matching `.rb` file in the plugin's `lib` directory (e.g.
> `pry-doc/lib/pry-doc.rb` will be loaded by Pry automatically unless explicitly
> configured otherwise.

Whew, what a mouthful! And what does it all mean? Let's break it down.

[From a certain point of view](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/11123401/obi-wan.png),
this definition is made up of three parts. One part describing how a Pry plugin
is composed and what it does:

> A Pry plugin is a gem that integrates with Pry

One part describing how a plugin does its thing:

> A Pry plugin integrates with Pry... typically by configuring environment
> behavior through Pry's customization API; altering or extending Pry's command
> system; and/or by registering behavior via Pry's system of life-cycle and REPL
> hooks.

And finally, one part describing one oddly particular facet of Pry convention:

> Plugins named with a `pry-` prefix (e.g. `pry-doc`) and including a matching
> `.rb` file in the plugin's `lib` directory (e.g.  `pry-doc/lib/pry-doc.rb`
> will be loaded by Pry automatically unless explicitly configured otherwise.

Since the first part of the definition is entirely unsatisfying in isolation and
the third part feels somewhat superfluous and arbitrary, let's focus on the meat
of our definition sandwich, which in this case is made up of three parts. We'll
talk about each of these subjects in more depth later, but for now here's a
little bit of background on each.

Pry's customization API is an easy to use API that allows for configuring many
of Pry's internals such as prompts, colors, printers, pagers, and more.
Depending on your particular use case, the customization API may be all that you
need to achieve the behavior you desire.

Next up we have Pry's command system. As you may have picked up on already, in
Pry terms, **commands** are the various special commands built into Pry like
`ls` or `whereami` that don't evaluate as Ruby code, but instead enhance the
shell experience in some way. In addition to Pry's built-in commands, many Pry
plugins extend Pry by adding new commands that further enhance and extend the
Pry experience.

Finally, Pry's system of hooks allows plugins to register behavior at various
points in Pry's life-cycle and cycle of reading and evaluating input and
outputting the result of that evaluation. Some Pry plugins even add new commands
**and** hook into Pry's system of hooks.

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

Adding new commands to Pry is one of the easiest ways to add new functionality
to Pry. Pry takes great pride in its command system as one of the things that
sets Pry apart from other REPLs. The trick up Pry's sleeve is that Pry commands
aren't methods like they might seem. Rather, they are special strings that are
caught by Pry before the input buffer is evaluated. This approach has a number
of advantages:

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

```{"language": "ruby", "gutter": false}
Pry.commands.import(PryMacro::Commands)
```

**Import a command set into the current Pry session from REPL:**

```{"language": "ruby", "gutter": false}
import-set PryMacro::Commands
```

**Add a command to the current Pry instance's command set:**

```{"language": "ruby", "gutter": false}
Pry::Commands.add_command(PryTheme::Command::PryTheme)`
```

```{"language": "ruby", "gutter": false}
Pry.commands.add_command(PryByebug::NextCommand)`
```

**Create a command directly on the REPLs default command set:**

```{"language": "ruby", "gutter": false}
Pry.commands.block_command("hello", "Say hello to three people") do |x, y, z|
  output.puts "hello there #{x}, #{y}, and #{z}!"
end
```

Though there are a couple of different variations on how it is achieved, each of
the above examples adds commands to Pry's default
[`Pry::CommandSet`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet).

A command set is Pry's mechanism for organizing groups of commands. The default
command set is automatically generated with Pry's built-in commands when Pry is
loaded and can be accessed via `Pry::Commands` or `Pry.commands` (a shortcut to
`Pry.config.commands`). As the previous examples demonstrated, whether to import
a whole command set into the default command set via the
[`Pry::CommandSet#import`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet#import-instance_method)
method, or to add just a single command via the
[`Pry::CommandSet#add_command`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet#add_command-instance_method)
method, the default command set is a frequent target of Pry plugins.

Although command sets also provide a rich DSL for defining new commands and
adding them to the set of commands, as is demonstrated above via
[`Pry::CommandSet#block_command`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet#block_command-instance_method),
I personally prefer to follow the pattern that Pry itself uses for all of its
built-in commands, which is a more traditional inheritance / class-based
approach that involves subclassing
[`Pry::ClassCommand`](http://www.rubydoc.info/github/pry/pry/Pry/ClassCommand).

By defining each command as its own class I find it reduces coupling and makes
testing easier and more flexible by removing extra complexity added by the
command set. Approaching each custom command as its own class also allows
flexibility later on, in that if I think a command should be added to a command
set down the road, I always have the freedom to do so using
`Pry::CommandSet.add_command`.

We'll look more at `Pry::ClassCommand` and the process of defining a class-style
command later when it's time to build our custom Pry plugin. For now though,
let's take a step back and consider another means of working with commands that
is handy in those situations where the goal is not to add an entirely new
command, but to modify the behavior of an built-in or otherwise existing
command.

### Command hooks

To facilitate customization and extension of existing commands, Pry includes a
couple of methods on each `Pry::CommandSet` instance that allow for registering
hooks that should fire before or after the matching command. This approach is
advantageous because it allows for modifying the behavior of a command in one
command set while leaving the behavior of that command unchanged in another
command set.

Aptly named, the methods to hook into the execution cycle of an existing
command,
[`Pry::CommandSet#before_command`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet#before_command-instance_method)
and
[`Pry::CommandSet#after_command`](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet#after_command-instance_method),
both take a matcher that will be used to determine which commands the hook
should be run for. In this fashion, it's actually possible to write a hook that
fires before or after all commands. This can be incredibly powerful, but it can
also be a little awkward to get the desired behavior when wrapping the execution
of a command at a higher level.


### REPL Hooks

## Let's make something!

### my_pry

#### command to set greeting

#### Hook to display greeting

# Afterthoughts

## Testing

## Next Steps

As it turns out, in retrospect, I think my initial roll-of-the-eyes was not in
response to Pry but to the co-worker who introduced me to it; every objection
I had with Pry really boiled down to me asking, "Dude, why must everything be
shiny with you?" Digression aside, the moral of the story is that Pry is a
powerful irb alternative architected for extension.

- [Pry Plugin Proposals](https://github.com/pry/pry/wiki/Plugin-Proposals)

## Additional Resources

- [Pry - An IRB alternative and runtime developer console](http://pryrepl.org/)
- [pry/pry - GitHub](https://github.com/pry/pry)
- [Pry - Available Plugins](https://github.com/pry/pry/wiki/Available-plugins)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [Pry::CommandSet - rubydoc.info](http://www.rubydoc.info/github/pry/pry/Pry/CommandSet)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)
