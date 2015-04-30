# Building an Application Command Shell with Pry
## tl;dr
## About Me
## A Brief Introduction to my Co-host, Pry
## Command Shells
### Why a Command Shell
### UIs
### CLIs
### The type of code this pattern is helpful for
## Pry Command Sets
### Pry Command Sets IRL
#### Using Command Sets
##### Importing and using the command set
- `import-set`
- `help`
##### Executing Commands
### Example Command Set Code
## Patterns For Command Set Construction
### POROs
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
### Command Pattern
### Query Pattern?
### Testing Your Commands!
#### POROs
#### Actually Testing Your Commands
## Going Further (In Brief)
### Advanced Command Set Behaviors
#### Slop
#### PryCommandSetRegistry
## tl;dr


Example Commands:
  - `tag-session`
