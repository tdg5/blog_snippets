Oh, hello there! Lovely to see you and what wonderful luck, you're just in time
for this week's exploration of building an application command shell with
[Pry](https://rubygems.org/gems/pry)! In this article, we'll look at using the
popular [Pry](https://rubygems.org/gems/pry) [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
to build a customized, interactive command shell for any type of Ruby
application, whether a production Rails app or a side project written in vanilla
Ruby.

Though the term [*command shell*](https://en.wikipedia.org/wiki/Shell_(computing))
is often used to refer to a command-line interface for interacting with
operating system services, for the purpose of this article we'll instead focus
on a command-line interface aimed at interacting with Ruby applications.

For this exploration we'll be adding a custom, somewhat generic, **tag-session**
command to Pry that will change the name the OS uses for the active Pry process
to include a tag of some sort. Though a bit contrived, this command can be
useful in situations where you want to distinguish between multiple active Pry
processes such as for tracking resource consumption or when multiple users share
a single user account on a remote machine and a particular user's Pry session
needs to be killed.

When all is said and done the **tag-session** command will be:
- available to import into Pry automatically or on-demand.
- listed in the output of Pry's **help** command.
- available to execute with a tag name given as an argument.

This article assumes you have some familiarity with Pry and have already
integrated Pry into your application such that you have a means of starting a
Pry console in the context of your application. If this isn't the case, never
fear, it's pretty easy to do and I'll cover a few resources for getting started
with Pry a little later. Before that though, let's consider why you might want
to extend your application with a command shell in the first place.

## The road so far

Today's exploration is inspired by some prototyping I've been doing at work to
build out a better pattern for handling a particular class of code that we've
never recognized or never really bothered to figure out a good means of dealing
with. I suspect many applications run into this type of code, maybe you've even
found yourself in one of these situations before:

- While working on a new feature, you throw together some code to setup, reset,
  enable, or disable that feature.
- While troubleshooting a production issue, you write a helper method for
  retrieving diagnostic information related to the issue or system the
  issue is occurring in.
- During a core meltdown or other critical system failure, you quickly hack
  together a command to annihilate the current system state in an attempt to get
  back to some kind of normal.

The code that comes into being in these types of situations is an awkward,
liminal class of code that defies common classification and organization
practices. On one hand, the code obviously relates to the function and operation
of the application, but at the same time it is not "application code" per se.
Instead it seems to exist at a layer beyond the application. Typically this code
is clearly not a model or application helper, and often doesn't feel at home in
the *lib* directory either.

Most often the fate of this type of code follows one of a multitude of
trajectories:

- The code is turned into a [rake](https://github.com/ruby/rake) task or a one-off
  script that lives somewhere in the *script* directory.
- The code is not added to the application in an executable fashion and instead
  is:
  - added to a kitchen sink style catchall for code of this sort;
  - added to related code as documentation;
  - added to the application's README document;
  - documented somewhere in the project's Wiki;
  - expatriated to some distant Confluence or Google Sites page;
- The code is discarded.

Making matters worse, the truth is that in reality the fate of this family of
orphaned code is not typically limited to just one of these trajectories but
instead probably follows each of the available paths with regularity. I hate to
say it, but I've personally sentenced innocent code snippets to every single one
of these fates. Certainly some of these outcomes are less ideal than others, but
even the inconsistency of it all smells.

Hopefully your situation isn't quite this bad or you're a wiser programmer than
I. Regardless, there seems to be a pattern here, a problem that we must first
identify before we can begin to solve.

## A problem emerges

It was not clear to me when I first began this project, but it seems to me now
that the family of code I've been focusing on finding a home for, the various
commands and queries, all have something in common. Something more specific than
just some intangible sense that they dwell in some other worldly ether beyond
the application.

all operator level interactions. 

Ultimately these are not the commands for interacting with your application, but
for interacting with the operating system of your application. Certainly there
are many tools for this, many of the individual components of the application
operating system will come with their own tools and command sets, but at some
point interactions with those components and systems seep into your code base
as you write libraries for interacting with those systems. Sure, anyone can
switch over to **psql** and reset a test database, but isn't it easier at some
point to have a rake task that does it? Is there not a point where adding an
additional layer of abstraction makes the problem more approachable to a Ruby
newbie or NoSQL advocate thrust into a relational application?



