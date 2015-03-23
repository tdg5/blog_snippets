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
for this week's exploration of building an interactive application [command-line
interface (CLI)](https://en.wikipedia.org/wiki/Command-line_interface) with
[Pry](https://rubygems.org/gems/pry)! In this article, we'll look at using
[Pry](https://rubygems.org/gems/pry) to build a customized, interactive
command-line interface for any type of Ruby application, whether a production
Rails app or a side project written in vanilla Ruby.

For this exploration we'll be adding a custom **tag-session** command to Pry
that will change the name of the Pry session as the OS sees it to include a tag
of some sort. Though a bit contrived, this command can be useful in situations
where you want to distinguish between multiple active Pry processes such as for
tracking resource consumption or when multiple users share a single user account
on a remote machine and a particular user's Pry session needs to be killed.

When we're done:
- The **tag-session** command can be imported into Pry automatically or on-demand.
- The **tag-session** command will be listed in the output of Pry's **help** command.
- Once imported the **tag-session** command can be executed with a tag name as
  an argument.

This article assumes you have some familiarity with Pry and have already
integrated Pry into your application such that you have a means of starting a
Pry console in the context of your application. If this isn't the case, never
fear, it's pretty easy to do and I'll cover a few resources for getting started
with Pry a little later. Before that though, let's consider why you might want
to extend your application with an interactive command-line interface in the
first place.

## When to use a CLI

First, let's start with some specifics of what I mean by a command-line
interface or CLI for the purposes of this article. As far as this article is
concerned, I think [Wikipedia](https://en.wikipedia.org/wiki/Command-line_interface)
nails it:

> A command line interface is a means of interacting with a computer program
> where the user (or client) issues commands to the program in the form of
> successive lines of text (command lines).

If you've ever used a [telnet](https://en.wikipedia.org/wiki/Telnet) client,
[git's interactive add mode](http://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging),
or a UNIX command shell like [sh](https://en.wikipedia.org/wiki/Bourne_shell)
or [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)), a command-line
interface should be pretty familiar to you as these are all examples of
command-line interfaces. In addition to their common CLI behavior, all of these
programs also feature an interactive mode where multiple commands can be
issued to the application before the program is terminated by the user.

In the Ruby world, [IRB](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell)
and [Rails console](http://guides.rubyonrails.org/command_line.html#rails-console)
are probably the most ubiquitous command shells, but there are many others out
there. For example, [Capistrano](https://rubygems.org/gems/capistrano) even has a built-in
command-line mode.

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
interfaces can be distilled to essentially taking in some kind of data from a
user, translating that data into a command to be executed against an
application, and returning the result of that command, if any, to the user.
Command-line interfaces are no different.

Although there are situations where a CLI may be the most suitable option, for
example for low-level interaction with remote machines or on some types of
hardware with limited graphical capabilities, for the purpose of this article I
want to approach the use of a CLI as a choice, not a mandate. When choosing an
appropriate interface, the decision to use a command-line interface hinges
mostly on the strengths and weaknesses of a CLI. The primary advantage

Even if you're an advocate for the command-line, there are still other
command-line options available that you may want to consider before moving
forward with a CLI. The most popular alternative to a dedicated CLI
is a more task-oriented library like [Thor](https://rubygems.org/gems/thor) or
the more ubiquitous [Rake](https://rubygems.org/gems/rake). These libraries
offer some of the benefits of a CLI in that they can be executed from bash
or another command shell, but typically the application is terminated after each
task and the user is returned to the environment from which they invoked the
task.


The strengths of a CLI are 

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
covering everything you might want to know over at [pryrepl.org](http://pryrepl.org/).

For the purposes of this article I think Pry is a great option for a number of
reasons, most of which stem from Pry's plugin-friendly design. Pry is built
for customization and offers many different ways to hook into Pry. As a result
there is a sizable community of [Pry plugins](https://github.com/pry/pry/wiki/Available-plugins).
Most offer tools for debugging application code, but Pry's plugin architecture
is sophisticated enough that there are very few restrictions on what can be
achieved by a Pry plugin.

One component that Pry allows you to easily extend and create plugins for is the
collection of special commands that Pry responds to. Pry's plugin system allows
you to extend the default collection of Pry commands by importing collections of
commands, called **command sets**, into the active session.

A **command set** is a collection of commands packaged and imported into a Pry
session as a group. Each command typically includes information on how it should
parse arguments, what group and description should be shown for the command in
Pry's **help** output, and how to execute the specified command.

Because extending the default set of commands is a common behavior, Pry has
a built-in command providing a consistent means to import a command set into the
current session, **import-set**. Simply call **import-set** with the name of the
command set you want to import, and Pry will do the rest, loading the commands
from that set into the environment and registering the descriptions of the
commands so they'll be shown in the output of Pry's **help** command.

Beyond Pry's built-in support for custom commands, another nice benefit of
implementing custom commands with Pry is that Pry commands are processed by Pry
differently than normal Ruby code. When Pry evaluates a line it first checks if
that line represents a command before trying to evaluate that line with as
Ruby. This means that Pry command names can follow patterns that normal Ruby
variables, methods, etc. can't. Take for example the **import-set** command I
mentioned a moment ago. Normally a name like **import-set** would cause an error
because **import-set** is not valid Ruby because Ruby identifiers can't include
a dash character. However, when Pry sees the string **import-set** it recognizes
it is a command before it passes it to the Ruby parser, so no error occurs.

I used to think this dashed naming was weird, but it's something I've come to
appreciate because the difference in naming syntax allows one to make a clear
distinction between what are variables and/or method names and what are Pry
commands. I think this is especially beneficial in situations where a command is
potentially destructive because the atypical syntax will force an invoker to
recognize that they are calling a specialized command which makes it harder to
accidentally invoke a command.

- particularly useful in cases where the result of the command is something you
  may want to manipulate in the console



Okay, onto the **tag-session** command!

## Crafting the command

Whether you choose to use Pry or another means to allow command-line interaction
with your application, the actual implementation of a command remains pretty
consistent. How you invoke the command will vary, but the actual implementation
of the execution of that command should not vary much. Depending on the
complexity of the command you seek to add, there are two common options for
defining the execution behavior of a command.

The simplest approach is to define the execution logic of the command in-line in
the body of the command definition in the Pry command set definition.
An alternative approach would be to encapsulate the logic, concerns, and
complexity of the command's execution logic into a new **Class** and simplify the
Pry command definition to whatever more minimal interaction is necessary to
invoke the desired behavior on the **Class** or one of its instances.

Again, depending on the complexity of the command, it may be overkill to break
off a new Class to encapsulate the behaviors of the command. That said, in all
but the simplest of cases this is the approach I would recommend. But for now,
let's ignore that advice and define the **tag-session** execution logic in-line.

Below is the absolute simplest version of the **tag-session** command:

```ruby
TagSessionCommandSet = Pry::CommandSet.new do
  command("tag-session", "Append a tag to the session name.") do |tag_name|
    $0 += "[#{tag_name}]"
  end
end
```

Once the above code has been loaded into a Pry session either by requiring a
file containing the above code or via copy-pasta, the command set can be
imported into the Pry session like so:

```ruby
import-set TagSessionCommandSet
```

Once the command set has been imported we can tag the Pry session using the
**tag-session** command. For example if I wanted to tag a session with my GitHub
user name I would execute the following:

```ruby
tag-session tdg5
```

### Why POROs?

Though it's more complex I think a Class-based approach 

Another big advantage I see in taking a Class based approach is that the
resulting Class is much easier to test than the same command defined in-line in
a Pry command. The main reason for this is that testing a plain old Ruby Class
should be a pattern that's pretty familiar to you, whereas testing a command
that's integrated with Pry might not be as familiar. That's not to say that I
don't think you should test the Pry command's handling of user input or the
interaction between the Pry command and a command Class. Rather, I think that
if the testing of the command Class can be handled in a normal unit testing
fashion you'll find b

- Easier to test
  - Don't require full pry environment and can be tested in isolation
  - Still should test interaction between Pry and PORO, but reduced test surface
- Command shell mostly only useful to developers, POROs leave the door open to
  other UIs in the future
- Skinny Pry Command Sets
- group sets of commands together that might be difficult to include together because of length of code or more distant relations of code
- can be difficult to manage which parts of a module are exposed to the environment when included; command interface minimizes and focuses API of included commands
- worry about fewer details of invoking commands
  - pry command should encapsulate most of the details of invoking command, making it much simpler to find and execute

```ruby
$0.sub(/script\/rails#.*/, "script/rails")
```

## Additional resources
- [Pry - An IRB alternative and runtime developer console](http://pryrepl.org/)
- [pry/pry - GitHub](https://github.com/pry/pry)
- [Command pattern - Wikipedia](https://en.wikipedia.org/wiki/Command_pattern)
- [Custom Commands - pry/pry Wiki](https://github.com/pry/pry/wiki/Custom-commands)
- [Command System - pry/pry Wiki](https://github.com/pry/pry/wiki/Command-system)
- [PryCommandSetRegistry gem | RubyGems.org](https://rubygems.org/gems/pry-command-set-registry)
- [tdg5/pry-command-set-registry - Github](https://github.com/tdg5/pry-command-set-registry)
