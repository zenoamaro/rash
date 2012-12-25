#!/usr/bin/env bash

# Rash example schema
# ===================

# This is an example schema file. Use this as a
# guide to build your own.



# Path to the file which contains the current migration step.
# You can also totally forgo to use a file if you want, e.g.,
# if you want to store the state in the db itself.
CURRENT_MIGRATION_FILE="current_migration"

# You can redefine the open and close tags for
# extracting migration steps if you want.
MIGRATION_UP_OPEN_TAG='<<<up'
MIGRATION_UP_CLOSE_TAG='up>>>'
MIGRATION_DOWN_OPEN_TAG='<<<down'
MIGRATION_DOWN_CLOSE_TAG='down>>>'

# You can redefine the function which enumerates
# the available migrations if you want.
function get_migrations_list {
	ls [0-9]* | sort -n
}

# You can redefine other core functions, if you need:
function format {
	local num=$1
	printf "%04d" $num
}



# Just an optional example which sets some variables
# in the global scope.
function get_connection_params {
	DB_HOST="localhost"
	DB_PORT="3339"
	DB_NAME="dbname"
	DB_USER="root"
	DB_PASS="somepassword"
}

# **REQUIRED**: This will be called from the migration procedure
# at the start of the migration. It will be passed
# all the extra parameters from the cli, so you could,
# for example, use them to choose an environment.
function setup {
	local env=$1
	get_connection_params $env
	echo Using db $(bold DB_NAME) as $(bold ${DB_USER}@${DB_HOST})
}

# **REQUIRED**: This will be called from the migration procedure
# at the end of the migration.
function teardown {
	echo Finished.
}

# **REQUIRED**: Return the current migration step id
# from this function.
function get_current_migration_step {
	if [[ -f "$CURRENT_MIGRATION_FILE" ]]; then
		echo $(<$CURRENT_MIGRATION_FILE)
	fi
}

# **REQUIRED**: Save the current migration step in the
# manner that you prefer.
function save_current_migration_step {
	local migration="$1"
	echo "$migration" > "$CURRENT_MIGRATION_FILE"
}

# **REQUIRED**: Execute the migration step itself.
# It will be passed the extract from the migration file.
function execute_migration_step {
	local query="$1"
	# echo Something went wrong while executing $query
	# return 1
}
