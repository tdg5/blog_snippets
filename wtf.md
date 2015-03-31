For the last two weeks I've been getting more or less nowhere while trying to
write a tutorial-style article demonstrating how to write custom commands for
the popular Pry REPL with a focus on repurposing Pry as an application command
shell for Ruby applications. The problem I keep running into is not the *how*
of the tutorial because Pry makes it dead-simple to add powerful new commands
and custom plugins. Rather, the issue I keep coming back to is *why*.

Certainly, some coverage of the *why* side of a tutorial is warranted, in fact
probably necessary, but each time I try to capture my thoughts on the matter I
find more thoughts than I can wrangle into a tutorial of reasonable length.

I wondered if this was some sort of unconscious troll-defense, but I don't think
that's it. I wondered if perhaps I was trying to include too much information
aimed at novice readers, but I don't think that's the issue either. Ultimately,
I think there are two threads in the sweater of *why* that keep looping me back
in.

First, this reflection is the product of trying to solve an inconsistency in the
production Rails application I work with everyday on the Backupify team at
Datto. An inconsistency that I think hints at, not necessarily a problem, but at
least a missing tool in the Ruby toolbox.

I debated splitting the article into two parts, but fluctuated on the matter
from day to day. Though I've rejected the idea several times, alas, here we are.
And so it seems I'm doomed to write this study of the benefits and use-cases
for building an application command shell in Ruby.

So without further ado,


