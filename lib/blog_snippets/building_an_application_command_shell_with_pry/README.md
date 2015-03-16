- Introduce idea and what will be covered
  - Example of what the product of this article will be
  - Pry - be brief, reference mostly external resources
  - Pry Command Sets
- When to use a command
- PORO command
  - Why POROs?
- Integrating with Pry
  - Creating the command set
  - Testing the command set
- Importing and using the command set
  - `import-set`
  - `help`
  - executing the command

- Future topics
  - Advanced Command Set behaviors
  - PryCommandSetRegistry


Oh, hello there! Lovely to see you and what wonderful luck, you're just in time
for this week's exploration of building an application [command-line interface
(CLI)](https://en.wikipedia.org/wiki/Command-line_interface) with
[Pry](https://rubygems.org/gems/pry)! In this article, we'll look at
using [Pry](https://rubygems.org/gems/pry) to build a customized command-line
application for any type of Ruby application, whether a production Rails app or
a side project written in vanilla Ruby.

For this exploration we'll be adding a custom **lalala** command to Pry such that
when we're done:
- The **lalala** command can be imported into Pry automatically or on-demand.
- The **lalala** command will be listed in the output of Pry's **help** command.
- Once imported the **lalala** command can be executed

This article assumes you have some familiarity with Pry and have already
integrated Pry into your application such that you have a means of starting a
Pry console in the context of your application. If this isn't the case, never
fear, it's not too hard to do and I'll cover some resources for getting started
with Pry a little later. Before that though, let's consider when you might want
to extend your application with a command-line interface in the first place.

## When to use a CLI

First, let's start with some specifics of what I mean by a CLI for the purposes
of this article. As far as this article is concerned, I think
[Wikipedia](https://en.wikipedia.org/wiki/Command-line_interface) nails it:

> A command line interface is a means of interacting with a computer program
> where the user (or client) issues commands to the program in the form of
> successive lines of text (command lines).

If you've ever used a [telnet](https://en.wikipedia.org/wiki/Telnet) client,
[git's interactive add
mode](http://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging), or a UNIX
command shell like [sh](https://en.wikipedia.org/wiki/Bourne_shell) or
[bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)), you should
be familiar with the notion of a command-line interface.

Ultimately, the choice to build a CLI is going to depend heavily on your
application and the target audience of the interface you are building.
Depending on how your target audience will prefer to issue commands to your
application and how you anticipate the target audience will want to interact
with the results of those commands, there are a wide array of alternatives that
might better suit your target audience.

The reality is that a CLI is just a specialized type of user interface. Every
user interface, whether a web app with a graphical user interface or a virtual
assistant with a voice driven user interface, suits a particular class of user
and problem. At their core, the purpose of all of these different types of user
interfaces can be distilled to essentially taking in data from a user,
translating that data into a command to be executed against an application, and
returning the result of that command, if any, to the user. Command-line
interfaces are no different.

Though a CLI may be the most suitable option for low-level interaction with
remote machines or some types of hardware with limited graphical capabilities,
for the purposes of this article I want to approach the use of a CLI as a
choice, not a mandate.

Even if you're an advocate for the command line, there are still other
command-line options available that you may want to consider before moving
forward with a CLI. The most popular alternative to a CLI
interface is a more task-oriented library like
[Thor](https://rubygems.org/gems/thor) or the more ubiquitous
[Rake](https://rubygems.org/gems/rake).

The decision to use a command-line interface hinges mostly on the strengths and
weaknesses of a CLI. 

- Some situations may be better for async jobs, rake/thor scripts. Judgment
  call.
- When the result of the command is something that you might want to manipulate
  in a Ruby/Pry


### Why Pry?

For those unfamiliar with [Pry](https://rubygems.org/gems/pry), Pry bills itself
as "a powerful alternative to the standard [IRB shell for
Ruby](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell)." Written from
scratch with advanced functionality in mind, if IRB was [Star Trek's Commander
Riker](https://en.wikipedia.org/wiki/William_Riker), Pry would be Riker, after
the beard. The full beardth, er, rather, breadth of Pry's awesomeness is too
much to go into in this post, but the team behind Pry has done a great job of
covering you might want to know over at [pryrepl.org](http://pryrepl.org/).

- consistent means of listing the command sets that are available without searching code base
  - this is particularly advantageous when on a remote server
  - also includes descriptions of intention of command sets
- consistent means of easily importing command sets
  - built into Pry
  - once imported, commands can be referenced with Pry's `help` command
  - `help` command also includes description of individual commands
- worry about fewer details of invoking commands
  - pry command should encapsulate most of the details of invoking command, making it much simpler to find and execute
- ability to use dashed names (like `show-source`) makes a clear distinction between what are commands and what are code snippets you've created in your environment.
  - also reduces chances of accidentally invoking command
- group sets of commands together that might be difficult to include together because of length of code or more distant relations of code
- can be difficult to manage which parts of a module are exposed to the environment when included; command interface minimizes and focuses API of included commands
- easier to test
- particularly useful in cases where the result of the command is something you
  may want to manipulate in the console

## Crafting the command PORO

### Why POROs?

- Easier to test
  - Don't require full pry environment and can be tested in isolation
  - Still should test interaction between Pry and PORO, but reduced test surface
- Command shell mostly only useful to developers, POROs leave the door open to
  other UIs in the future
- Skinny Pry Command Sets

## Additional resources
- [Pry - An IRB alternative and runtime developer console](http://pryrepl.org/)
- [pry/pry - GitHub](https://github.com/pry/pry)
- [Command pattern - Wikipedia](https://en.wikipedia.org/wiki/Command_pattern)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)
