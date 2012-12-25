#!/usr/bin/env bash



# Returns the list of migration files.
# Defaults to all numbered files.
#     get_migration_list
#     > 0001.sql 0002_whatever.sql 0003_other.sql
function get_migrations_list {
	ls [0-9]* | sort -n
}

# Returns true if the current and target migration
# are still in the range of valid migration steps.
#     still_migrating up 0003 0004
#     > 0
#     still_migrating down 0003 0004
#     > 1
function still_migrating {
	local dir=$1
	local current=$2
	local target=$3

	if [[ ($dir == 'up'   && $current -lt $target) || \
          ($dir == 'down' && $current -gt $target) ]]
    then
      	echo 0
    else
    	echo 1
    fi
}

# Extracts the migration snippet from the file,
# based on the current direction. Uses the tags defined
# in `$MIGRATION_DIR_X_TAG`.
#     get_migration_step up 0001.sql
#     > ...snippet between tags
function get_migration_step {
	local dir=$1
	local file="$2"

	if [ $dir == 'up' ]; then
		extract "$file" "$MIGRATION_UP_OPEN_TAG" "$MIGRATION_UP_CLOSE_TAG"
	elif [ $dir == 'down' ]; then
		extract "$file" "$MIGRATION_DOWN_OPEN_TAG" "$MIGRATION_DOWN_CLOSE_TAG"
	fi
}
