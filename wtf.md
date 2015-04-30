For the last two weeks I've been getting more or less nowhere while trying to
write a tutorial-style article demonstrating how to write custom commands for
the popular Pry REPL with a focus on repurposing Pry as an application command
shell for Ruby applications. The problem I keep running into is not the *how*
of the tutorial because [Pry makes it redonkulously simple to extend your pry
experience with powerful new commands](https://github.com/pry/pry/wiki/Custom-commands)
and [custom plugins](https://github.com/pry/pry/wiki/Plugins). Rather, the issue
I keep coming back to is *why*.

Certainly, some coverage of the *why* side of a tutorial is warranted, in fact
probably necessary, but each time I try to capture my thoughts on the matter I
find more thoughts than I can wrangle into a tutorial of reasonable length.

At first, I wondered if this was some sort of unconscious preemptive
troll-defense, but I don't think that's it (and really, what hope of defense do
I have anyway?). I also wondered if perhaps I was trying to include too much
information aimed at novice readers, but I don't think that's the issue either.
Ultimately, I think there are two threads in the sweater of *why* that keep
looping me back in.

First, this reflection is the product of trying to solve an inconsistency in the
production Rails application I work with everyday on the Backupify team at
Datto. An inconsistency that I think hints at, not necessarily a problem, but at
least an under recognized class of code or perhaps a weapon that's missing from the
Ruby arsenal.

Second, if there is a problem here that needs to be addressed, what benefits
does an application command shell offer for addressing that pain? Even if a
command shell can help reduce the pain in some situations, in what situations is
it less appropriate?

I've debated splitting the article into two parts, but fluctuated on the matter
from day to day. Though I've rejected the idea several times, alas, here we are.
And so it seems I'm doomed to write this study of the benefits and use-cases
for building an application command shell in Ruby.

In my next article, with all this background purged from my system, we'll look
into extending Pry with a custom command.

So without further ado, thoughts in paragraph form!

## The road so far

Today's exploration is inspired by some prototyping I've been doing at work to
build out a better pattern for handling a particular class of code that we've
never recognized or never really bothered to figure out a good means of dealing
with. I suspect many applications run into this type of code, maybe you've even
found yourself in one of these situations before:

- While working on a new feature, you throw together some code to setup, reset,
  enable, or disable that feature or a related service.
- While troubleshooting a production issue, you write a helper method for
  retrieving diagnostic information related to the feature or system the
  issue is occurring in.
- During a core meltdown or other critical system failure, you quickly hack
  together a command to annihilate some part of the current system state in an
  attempt to get back to some kind of normal.

The code that comes into being in these types of situations is an awkward,
liminal class of code that defies common classification and organization
practices. On one hand, the code obviously relates to the function and
*operation* of the application, but at the same time it is not "application
code" per se. Typically this code is clearly not a model or application helper,
and often doesn't feel at home in the *lib* directory either. Instead, it seems
to exist at a layer beyond the application.

Most often this type of code suffers one of a multitude of common fates:

- The code is turned into a [rake](https://github.com/ruby/rake) task or a
  [Thor](https://github.com/erikhuda/thor) script and stashed away somewhere in
  the application.
- The code is not added to the application in an executable fashion and instead
  is:
  - added to a kitchen sink style catchall for code of this sort;
  - added to related code as documentation;
  - added to the application's README document;
  - documented somewhere in the project's Wiki;
  - expatriated to some distant Confluence or Google Sites page;
- The code is discarded.

Making matters worse, in reality the fate of this family of orphaned code is not
typically limited to just one of these trajectories but instead probably follows
each of the available paths with regularity. I hate to say it, but I've
personally sentenced innocent code snippets to every single one of these fates.
Certainly some of these outcomes are less ideal than others, but even the
inconsistency of it all smells.

Hopefully your situation isn't quite this bad or you're a wiser programmer than
I. Regardless, there seems to be a pattern here, a problem that we must first
identify before we can begin to understand how an application command shell can
help.

## A problem emerges

It was not clear to me when I first began this project, but it seems to me now
that the family of code I've been focused on finding a home for, the various
commands and queries, all have something in common. Something more specific than
that intangible sense that they dwell in some other worldly ether beyond
the application.

The pattern that has gradually emerged to me is that these examples are all
operational interactions. Unlike most of an application's code which tends to
focus on how a **user** interacts with the application, these types of
interactions tend to deal with how an admin, **operator**, or engineer operates
and administrates your application. Ultimately, the distinction boils down to
code for operating your application and the ecosystem it exists within, as
opposed to the more common case of code for using your application.

This is not to say that there are not solutions in the Ruby universe for dealing
with operational instructions. The aforementioned [rake](https://github.com/ruby/rake)
and [thor](https://github.com/erikhuda/thor) libraries are both popular options
for encapsulating operational tasks in an easily executable manner. Even vanilla
Ruby scripts are often sufficient for handling these types of interactions.

Certainly there are many tools for this. Many of the individual components of
the application's ecosystem will come with their own tools and command
sets, but at some point interactions with those components and systems seep into
your code base as you write libraries for interacting with those systems. Sure,
anyone can switch over to **psql** and reset a test database, but isn't it
easier at some point to have a rake task that does it? Is there not a point
where adding an additional layer of abstraction makes the problem more
approachable to a Ruby newbie or NoSQL advocate thrust into a relational
application?

And yet here we are. As an example, consider my work on Datto's Backupify web
application. The Backupify application is a monolithic Rails app that includes
operational code/command/queries in each of the following flavors: PORS (Plain
old Ruby scripts), rake tasks, Thor scripts, bash scripts,
[rubber](https://github.com/rubber/rubber) tasks, and we even have **three**
kitchen sink catchalls, aptly named "useful_console", "useful_queries", and
"useful_shell".

It's a little bewildering to think that really need to have so many flavors


Having established that there's some kind of inconsistency or gap, let's look at
how an application command shell might help sooth this tension.

## Command shell vs. CLI: What's in a name?

Though I've talked about the notion of a *command shell* a little bit already,
let's outline a few specifics to make sure we're on the same page. If you feel
like you've already got a good handle on the distinction between a *command-line
interface* and a *command shell*, feel free to skip this section.

Conceptually, a *command shell* is a specialized *command-line interface* or
*CLI*. The [Wikipedia article on command-line interfaces](https://en.wikipedia.org/wiki/Command-line_interface)
summarizes the concept of a CLI nicely:

> A command line interface is a means of interacting with a computer program
> where the user (or client) issues commands to the program in the form of
> successive lines of text (command lines).

This definition covers the bulk of the what I think of when I think of a
*command shell*, with one exception.

In my opinion, the key characteristic that distinguishes a *command shell* from
a *CLI* is execution context. Whereas a *CLI* typically offers an interface that
is invoked from and returns to an outside context, a *command shell* is
typically invoked from an outside context, but does not return to that outside
context immediately. Instead, a *command shell* offers its own session-based
execution context in which multiple commands can be issued successively. The
words to clearly describe this distinction elude me, so perhaps an example
will better illustrate the difference.

Let us consider the UNIX [**bash**](https://en.wikipedia.org/wiki/Bash_(Unix_shell))
utility for a moment. Though **bash** is inarguably a *command shell*, it also
offers a more *CLI-like* interface when invoked with the **-c** option. Let's
take a look at running an **ls** command with both variations.

**A more CLI-like usage of bash:**

```bash
some other shell> bash -c "ls -l"
total 16
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:50 some_file
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:50 some_other_file
some other shell>
```

In the above example you can see that when given the **-c** argument, **bash**
behaves more like a one-off command than a *command shell*. In this example,
rather than following the more familiar behavior of starting a new **bash** shell
session for the user to interact with, instead, **bash** creates a new context to
execute the given **ls** command, executes the command, and then returns
immediately to the calling context of **some other shell**.

Now consider the same **ls** command, but this time executed from a full-fledged
**bash** *command shell*:

**Command shell bash:**

```bash
some other shell> bash
bash $ ls -l
total 16
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:50 some_file
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:53 some_other_file
bash $ exit
some other shell>
```

Though quite similar, this example brings the *command shell* nature of **bash** to
the foreground. Once **bash** is executed, the execution context of the shell
changes from **some other shell** to **bash**. Even after the **ls** command is
executed, the **bash** context persists. It's not until an **exit** command is
issued that the execution context returns to **some other shell**.

I know this may seem like a lot of effort to go into just to distinguish a
*command shell* from a *CLI*, but in the Ruby ecosystem where there are numerous
tools for building *command-line interfaces* and numerous *REPLs*, I've found
there's a surprising lack of innovation when it comes to *command shells*.

## When to use a command shell

Ultimately, the choice to build any variety of command-line interface is going
to depend heavily on your application and the target audience of the interface
you are building. Depending on how your target audience will prefer to issue
commands to your application and how you anticipate the target audience will
want to interact with the results (and failures) of those commands, there are a
wide array of options that might better suit your target audience. The reality
is that a CLI is just a specialized type of user interface and every user
interface, whether a web app with a graphical user interface or a virtual
assistant with a voice driven user interface, suits a particular class of user
and problem.

In his book [Confident Ruby](http://www.confidentruby.com/)
[[sample]](http://devblog.avdi.org/wp-content/uploads/2013/08/confident-ruby-sample.pdf),
[Avdi Grimm](http://about.avdi.org/) presents the idea that every line of code
in the body of a method definition serves one of four purposes: Collecting input,
performing work, delivering output, or handling failures. I think the same is
largely true of a user interface. Restated in terms of user interfaces, the
purpose of any user interface is to: take in some kind of data (input) from a
user, translate that data into a command, execute the command, and finally
return the result or failure of that command (if any) to the user.

Command-line interfaces are no different from other UIs in this regard. However,
unlike other more graphical UIs, CLIs serve a pretty niche audience, typically
characterized by IT admins, software professionals, and the hacker cliche. There
are exceptions, of course, but those tend to be scenarios where a CLI is the
most suitable option, regardless of the sophistication of the target audience.
Those scenarios tend to be environment or hardware specific, for example
situations that require low-level interaction with remote machines or on some
types of hardware with limited graphical capabilities.

If you're reading this article, chances are that your target environment offers
few options beyond a CLI or your audience is sufficiently sophisticated that
this may not be a concern. In fact, if your target audience is one of those
types of users, a CLI can be a great option for providing a sophisticated,
automation friendly means of communicating with your application. That said,
don't forget that if your application is a Rails web app or some other kind of
remote application, a CLI is only going to benefit those users that have some
means of connecting to your remote servers directly, with something like
**SSH**, or indirectly via another protocol.

If none of this concerns you, great! But even if you're an advocate for the
command-line, there are many other command-line options available that you may
want to consider before moving forward with a command shell. The most popular
alternative to a dedicated command shell is a more task-oriented library like
[Thor](https://rubygems.org/gems/thor) or the more ubiquitous
[Rake](https://rubygems.org/gems/rake). These libraries offer the benefits of a
CLI in that they can be executed from **bash** or another OS level command
shell, but typically after performing the specified task or tasks, the
application is terminated and the user is returned to the environment from which
they invoked the task.

As we saw earlier with **bash**, a command shell can be a great option for issuing
multiple commands in succession. This can be of particular value in situations
where the time to load the environment is a sizable portion of the time taken to
execute the task since a command shell would only need to load the environment
once and could execute any number of commands thereafter. Rails is probably the
most popular example of a library that can take some time to load the
environment, but with the introduction of libraries like
[zeus](https://rubygems.org/gems/zeus) and [spring](https://rubygems.org/gems/spring),
this tends to be less of a problem than it once was.

A command shell can also be a great option in situations where the result of a
command is something that your target audience may want to manipulate with the
full awesomeness of Ruby. This can be particularly handy when the result of a
command is a database record the user may want to manipulate or in Ruby dev
shops where **bash** skills may not be in excess (which is a whole other problem).
