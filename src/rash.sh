#!/usr/bin/env bash

# Rash
# ====

## A migration tool written in Bash.

# This is a simple tool to perform ordered migrations steps of whatever nature,
# requiring only the definition of a few functions in a schema script.
#
# Usage:
#     rash [migration number]



# Preparation
# -----------

# Get the absolute path to the script
pushd $(dirname $0) > /dev/null; RASH_PATH=$(pwd -P); popd > /dev/null

source "$RASH_PATH/rash_utils.sh"
source "$RASH_PATH/rash_migrations.sh"

# Path to the shell file which contains the migration parameters.
SCHEMA_FILE="schema.sh"
# Default path to the file which contains the current migration step.
CURRENT_MIGRATION_FILE="current_migration"

# Default open and close tags for extracting migration steps.
MIGRATION_UP_OPEN_TAG='<<<up'
MIGRATION_UP_CLOSE_TAG='up>>>'
MIGRATION_DOWN_OPEN_TAG='<<<down'
MIGRATION_DOWN_CLOSE_TAG='down>>>'

# We'll source the configuration file here, to allow it to redefine
# things if he wants.
if [[ -f $SCHEMA_FILE ]]; then
	source $SCHEMA_FILE
else
	echo $(error No schema file \"$SCHEMA_FILE\" has been found!)
	exit 1
fi



# List of every migration in the dir, ordered by number.
migrations=( $(get_migrations_list) )

# This will be the passed args.
target_migration=$1

# No migration specified means migrating to the last.
if [ -z $target_migration ]; then
	target_migration=$(format $(numeric $(last ${migrations[@]} )))
fi

# Get the current migration
current_migration=$( format $(get_current_migration_step) )

# Default migration is 0000 (as in no migration)
if [[ -z $current_migration ]]; then
	current_migration=$( format 0 )
fi



# Starting migration
# ------------------

echo Current migration is $(bold $current_migration), desired one is $(bold $target_migration).

# Don't do anything if there's no need to.
if [[ $current_migration == $target_migration ]]; then
	echo Nothing do be done.
	exit 0
fi

# Infer the direction from the requested migration steps.
dir=$(direction $current_migration $target_migration)

setup



# Actual migration step
# ---------------------

while [[ $(still_migrating $dir $current_migration $target_migration) -eq 0 ]]; do

	# When going up we'll execute the next, not 0000.
	# When going down, on the other hand, we'll need to execute the DOWN part
	# of the current step first, so we won't decrease till later on.
	if [[ $dir == 'up' ]]; then
		current_migration=$(format $(ordinal $dir $current_migration) )
	fi

	migration_file=$( first ${current_migration}* )
	migration_query=$( get_migration_step $dir "$migration_file" )

	echo - Executing $dir migration $(bold "$migration_file")

	# Execute the migration step
	catch_errors execute_migration_step $migration_query

	# Now's the time to decrease.
	if [[ $dir == 'down' ]]; then
		current_migration=$(format $(ordinal $dir $current_migration) )
	fi

	# Store the current migration and go on.
	save_current_migration_step $current_migration

done

# Whew, That wasn't so bad.

teardown