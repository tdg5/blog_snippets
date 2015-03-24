Oh, hello there! Lovely to see you and what wonderful luck, you're just in time
for this week's exploration of building an application command shell with
[Pry](https://rubygems.org/gems/pry)! In this article, we'll look at using
[Pry](https://rubygems.org/gems/pry) to build a customized, interactive
command-line interface (CLI)](https://en.wikipedia.org/wiki/Command-line_interface)
for any type of Ruby application, whether a production Rails app or a side
project written in vanilla Ruby.

Though the term [*command shell*](https://en.wikipedia.org/wiki/Shell_(computing))
is often used to refer to a command-line interface for interacting with
operating system services, for the purpose of this article we'll instead focus
on a command shell aimed at interacting with a Ruby application.

For this exploration we'll be adding a custom **tag-session** command to Pry
that will change the name the OS uses for the active Pry process to include a tag
of some sort. Though a bit contrived, this command can be useful in situations
where you want to distinguish between multiple active Pry processes such as for
tracking resource consumption or when multiple users share a single user account
on a remote machine and a particular user's Pry session needs to be killed.

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
let's outline a few specifics to make sure we're starting on the same page.
Conceptually, a *command shell* is a specialized *command-line interface* or
*CLI*. The [Wikipedia article on command-line interfaces](https://en.wikipedia.org/wiki/Command-line_interface)
summarizes the concept of a CLI nicely:

> A command line interface is a means of interacting with a computer program
> where the user (or client) issues commands to the program in the form of
> successive lines of text (command lines).

This definition covers the bulk of the what I think of when I think of a
*command shell*, with one exception. In my opinion, the key characteristic that
distinguishes a *command shell* from a *CLI* is execution context. Whereas a
*CLI* typically offers an interface that can be invoked from an outside context,
a *command shell* has its own session-based execution context. Execution context
doesn't feel like quite the right word, so perhaps an example will better
illustrate the difference.

Let us consider the UNIX [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))
utility for a moment. Though bash is inarguably a command shell, it also offers
a more CLI-like interface via the **-c** option. Let's take a look at both:

**A more CLI-like usage of bash:**
```bash
some other shell> bash -c "ls -l"
total 16
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:50 some_file
-rw-rw-r-- 1 tdg5 tdg5 0 Mar 24 08:53 some_other_file
some other shell>
```

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



I know this may seem like a lot of effort to go into just to distinguish a
*command shell* from a *CLI*, but in an ecosystem where there are numerous tools
for building out *command-line interfaces*, and l


## When to use a command shell
