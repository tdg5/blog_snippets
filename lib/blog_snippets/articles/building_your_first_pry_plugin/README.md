When I was first introduced to the `pry` gem and the alternative Ruby CLI
experience it provides, I have to admit, I didn't get it. I didn't understand
why `pry` was a better option than `irb` or more typically for me, `rails
console`. Sure, built-in commands like `ls` make the CLI experience nicer, but
you could already get similar information by executing a snippet along the lines
of `target.methods.sort - Object.methods`, and what's not nice about typing that
10x a day?

Luckily for you and I (but not my love of typing `Object.methods`), I changed
jobs into a dev environment where `pry` via `pry-rails` was the de facto `rails
console` replacement and thanks in large part to its debugging story and the
power of `binding.pry`, I've never looked back.

As it turns out, in retrospect, I think my initial roll-of-the-eyes was not in
response to `pry` but to the co-worker who introduced me to it; every objection
I had with `pry` really boiled down to me asking, "Dude, why must everything be
shiny with you?" Digression aside, the moral of the story is that `pry` is a
powerful `irb` alternative architected for extension.

To that end, in this article, we'll look at the basics of creating a `pry`
plugin, from what constitutes a plugin and why you might want to create one to
the various hooks and other means `pry` provides for plugin integration. To do
this, we'll be creating a `pry` plugin that customizes `pry` with a custom
greeting and can also be used as a sandbox for your future `pry` endeavors.

First though, a little bit about `pry`! This article assumes you have some
familiarity with `pry`, but if this isn't the case, never fear, I'll cover some
resources for getting started with `pry` momentarily.

## What is Pry?

For those unfamiliar with [`pry`](https://rubygems.org/gems/pry), `pry` bills
itself as "a powerful alternative to the standard [`irb` shell for
Ruby](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell)." Written from
scratch with advanced functionality in mind, if IRB was [Star Trek's Commander
Riker](https://en.wikipedia.org/wiki/William_Riker), `pry` would be Riker, after
the beard. The full beardth, er, rather, breadth of the awesomeness of `pry` is
too much to go into in this article, but the team behind `pry` has done a great
job of covering you might want to know over at
[pryrepl.org](http://pryrepl.org/).

### What is a Pry plugin, anyway?

So that we're all starting on the same page, let's begin by defining what
constitutes a `pry` plugin. Don't worry if this definition doesn't make
immediate and total sense, as we'll dig more into the details as we explore.
Okay, here goes: A `pry` plugin is a gem or library designed to integrate with
and extend `pry` either by augmenting `pry` with new commands or by hooking into
the `pry` read-eval-print loop to add new behavior.

Whew, that's a mouthful. Since I imagine it's the second half of that sentence
that will elicit the most blank stares, let's look at the different kinds of
`pry` plugins to shed some light on how they do their thing.

#### Kinds of plugins

#### Plugin uses
Plugins typically fall into one of a few common categories based on the type of
functionality they provide:
  - Debugging tools
    - [pry-byebug](https://github.com/deivid-rodriguez/pry-byebug)
  - - [pry-remote](https://github.com/mon-ouie/pry-remote)
  - Command-line interface (CLI) / Command shell
    - [pry-rails](https://github.com/rweng/pry-rails)
  - Tweaks and enhancements to `pry` itself
    - [pry-coolline](https://github.com/pry/pry-coolline)
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
- [Command pattern - Wikipedia](https://en.wikipedia.org/wiki/Command_pattern)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)
## Next Steps


