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
on a command shell aimed at interacting with a Ruby application.

For this exploration we'll be adding a some custom, somewhat generic,
**tag-session** command to Pry that will change the name the OS uses for the
active Pry process to include a tag of some sort. Though a bit contrived, this
command can be useful in situations where you want to distinguish between
multiple active Pry processes such as for tracking resource consumption or when
multiple users share a single user account on a remote machine and a particular
user's Pry session needs to be killed.

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
  enable, disable, etc. that feature.
- While troubleshooting a production issue, you write a helper method for
  retrieving diagnostic information related to the issue or system the
  issue is occurring in.
- During a core meltdown or other critical system failure, you quickly hack
  together a command to annihilate the current system state in an attempt to get
  back to some kind of normal.

The code that comes into being in these types of situations is an awkward,
liminal class of code that defies common classification and organization
practices. On one hand, the code obviously relates to the function and operation
of the application, but at the same time it seems to exist at a layer beyond the
application. Typically this code is clearly not a model or application helper,
and often doesn't feel at home in the *lib* directory either. Most often the
fate of this type of code follows one of a multitude of trajectories:

- The code is turned into a one-off script and added to the *script*
  directory.
- The code is not added to the application in an executable fashion and instead
  is:
  - added to a kitchen sink style catchall for code of this sort;
  - added to related code as documentation;
  - added to the application's README document;
  - documented in the project's Wiki;
  - expatriated to some distant Confluence or Google Sites page;
- The code is discarded.

Making matters worse, the truth is that in reality the fate of this orphaned
code is not typically limited to just one of these trajectories but instead
probably follows each of the available paths with regularity. I hate to say it,
but I've personally sentenced innocent code snippets to every single one of
these fates.

Hopefully your situation isn't quite this bad or you're a better programmer than
I am. Regardless, there seems to be a pattern here, a problem that must be
identified before it can be solved.

## A problem emerges

It was not clear to me when I first began this project, but it seems to me now
that all of this code, the various commands and queries, are all operator level
interactions. 
