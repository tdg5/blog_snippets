When I was first introduced to the [pry](https://rubygems.org/gems/pry) gem
and the alternative Ruby
[CLI](https://en.wikipedia.org/wiki/Command-line_interface) /
[REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
experience it provides, I have to admit, I didn't get it. I didn't understand
why `pry` was a better option than `irb` or more typically for me, `rails
console`. Sure, helpful commands built into pry like `ls` make for a nicer CLI
experience, but you could already get similar information by evaluating a
snippet along the lines of `target.methods.sort - Object.methods`, and what's
not nice about typing that 10x a day?

Luckily for you and I (but not my love of typing `Object.methods`), shortly
after my introduction to pry I switched jobs into a dev environment where `pry`
(via [`pry-rails`](https://github.com/rweng/pry-rails)) was the de facto `rails
console` replacement and thanks in large part to its debugging story and the
power of `binding.pry`, I've never looked back.

As it turns out, in retrospect, I think my initial roll-of-the-eyes was not in
response to pry but to the co-worker who introduced me to it; every objection
I had with pry really boiled down to me asking, "Dude, why must everything be
shiny with you?" Digression aside, the moral of the story is that pry is a
powerful irb alternative architected for extension.

To that end, in this article, we'll look at the basics of creating a pry
plugin, from what constitutes a plugin and why you might want to create one, to
the various hooks and other means pry provides for plugin integration. To do
this, we'll be creating a pry plugin that customizes pry with a custom
greeting and can also be used as a sandbox for your future pry endeavors.

First though, a little bit about pry! This article assumes you have some
familiarity with pry, but if this isn't the case, never fear, I'll cover some
resources for getting started with pry next.

## What is Pry?

For those unfamiliar with pry, pry bills itself as

> A powerful alternative to the standard [`irb` shell for
> Ruby](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell)

Written from scratch with advanced functionality in mind, if IRB was [Star
Trek: The Next Generation's Commander
Riker](https://en.wikipedia.org/wiki/William_Riker), pry would be Riker, after
the beard.

![Commander William T.  Riker](https://s3.amazonaws.com/tdg5/blog/wp-content/uploads/2015/06/04124355/riker.jpg)

The full beardth, er, rather, breadth of the awesomeness of pry is
too much to go into in this article, but the team behind pry has done a great
job of covering most of what you might want to know over at
[pryrepl.org](http://pryrepl.org/).

At a glance, some of the advantages of pry are:

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

On top of all those built-in features, pry is enormously extensible with an
ecosystem of fun and powerful plugins contributed and maintained by the
pry community.

All that said, if you haven't tried pry, I strongly recommend doing so. There's
really no substitute for spending a few minutes playing around in a pry shell to
explore the conveniences and utility it offers.

At this point, I'm going to assume you're sold on pry (if you weren't already),
and move on to the main focus of this article, pry plugins.

### What is a Pry plugin, anyway?

So that we're all starting on the same page, let's begin by defining what
constitutes a pry plugin. Don't worry if this definition doesn't make
immediate and total sense, as we'll dig more into the details as we explore.
Okay, here goes:

> A pry plugin is a gem or library designed to integrate with and extend pry
> either by augmenting pry with new commands or by hooking into the pry
> [read-eval-print loop](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) to
> add new behavior.

Whew, that's a mouthful. Since I imagine it's the second half of that sentence
that will elicit the most blank stares, let's look at some of the different
kinds of pry plugins that exist out in the wild to shed some light on how they do
their thing.

#### Pry's wild world of plugins

Plugins typically fall into one of a few common categories based on the type of
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
[Pry - Available Plugins](https://github.com/pry/pry/wiki/Available-plugins)

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

- [Pry - An IRB alternative and runtime developer console](http://pryrepl.org/)
- [pry/pry - GitHub](https://github.com/pry/pry)
- [Pry - Available Plugins](https://github.com/pry/pry/wiki/Available-plugins)
- [Command pattern - Wikipedia](https://en.wikipedia.org/wiki/Command_pattern)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)

## Next Steps

- [Pry Plugin Proposals](https://github.com/pry/pry/wiki/Plugin-Proposals)
