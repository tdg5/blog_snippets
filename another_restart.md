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

## Command shell vs. CLI: What's in a name?

Though I've talked about the notion of a *command shell* a little bit already,
let's outline a few specifics to make sure we're starting on the same page. If
you feel like you've already got a good handle on the distinction between a
*command-line interface* and a *command shell*, feel free to skip this section.

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
session for the user to interact with, **bash** instead creates a new context to
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

I hope this explanation and example helps clarify the distinction, at least in
my mind, between a vanilla *command-line interface* and a more interactive
*command shell*. I know this may seem like a lot of effort to go into just to
distinguish a *command shell* from a *CLI*, but in the Ruby ecosystem where
there are numerous tools for building *command-line interfaces* and numerous
*REPLs*, I find there's a surprising lack of innovation when it comes to
*command shells*.

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
in the body of a method serves one of four purposes: Collecting input,
performing work, delivering output, or handling failures. I think the same is
largely true of a user interface, though I think failure handling has a less
pronounced role. Restated in terms of user interfaces, the purpose of any user
interface is to: take in some kind of data (input) from a user, translate that data into
a command, execute the command, and finally return the result or failure of that
command (if any) to the user.

Command-line interfaces are no different from other UIs in this regard. However,
unlike other more graphical UIs, CLIs serve a pretty niche audience, typically
characterized by IT admins, software professionals, and hackers. There are
exceptions, of course, but those tend to be scenarios where a CLI is the most
suitable option, regardless of the sophistication of the target audience. Those
scenarios tend to be environment or hardware specific, for example situations
that require low-level interaction with remote machines or on some types of
hardware with limited graphical capabilities.

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
shell, but typically after performing the specified task(s), the application is
terminated and the user is returned to the environment from which they invoked
the task.

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


