Rash
====

### A migration tool written in Bash.

This is a simple tool to perform ordered migrations steps of whatever nature,
requiring only the definition of a couple functions in a schema script.



Usage
-----

To use this, pick an example from the schemas, customize as you need and then
save it as `schema.sh` into a directory, along with migrations numbered at the
front, starting from `0001`.

Migrations should contain both UP and DOWN steps, marked by default inside
`<<<up ... up>>>` and `<<<down ... down>>>` delimiters.

Then launch `rash.sh` with the desired migration number, or without arguments
if you want to migrate to the last available one. This will execute all the
steps from the current one to the desired one. Migrating towards `0000` instead
will undo all migration steps.

	rash/test $ ls
	0001_initial_migration     0003                       schema.sh
	0002 migration with spaces 0004_another_one

	rash/test $ bash ../src/rash.sh
	Current migration is 0000, desired one is 0004.
	Using env default as user maint-user
	- Executing up migration 0001_initial_migration
	- Executing up migration 0002 migration with spaces
	- Executing up migration 0003
	- Executing up migration 0004_another_one
	Finished.



Roadmap
-------

- Commands, like status, migrate and reset
- Use the list of migrations, instead of working with numerals
- Allow the schemas to define custom commands
- Allow having more than one schema
- More customization options and hooks for schemas
- A build step to produce a single stand-alone script
- CLI arguments, inline help and usage
- Better documentation and example schemas
- Complete coverage of unit tests


FAQ
---

##### Why would you write something like this in Bash?

It is lightweight, and not actually limited to database schema migrations,
so it could be of some use. It is also an exercise in writing good shell
code. But mainly because I could.

##### Why in Earth should I use this?

I have no idea.