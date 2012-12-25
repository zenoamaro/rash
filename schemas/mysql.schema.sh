#!/usr/bin/env bash



# Rash example mysql schema
# =========================

# This is an example schema file for mysql. Customize this
# and save it as "schema.sh".



# Path to the file which contains the current migration step.
# TODO: This should be stored in the db itself.
CURRENT_MIGRATION_FILE="current_migration"

# List only sql files.
function get_migrations_list {
	ls [0-9]*.sql | sort -n
}

# Retrieve some connection parameters.
# TODO: Use some kind of env parameter when it's done.
function get_connection_params {
	local env=$1
	DB_HOST="localhost"
	DB_PORT="3339"
	DB_NAME="dbname"
	DB_USER="root"
	DB_PASS="somepassword"
}

# Get the connection parameters for the environment
# and print a notice about the connection attempts.
function setup {
	local env=$1
	get_connection_params $env
	echo Using db $(bold DB_NAME) as $(bold ${DB_USER}@${DB_HOST})
}

# Return the current migration step id.
function get_current_migration_step {
	if [[ -f "$CURRENT_MIGRATION_FILE" ]]; then
		echo $(<$CURRENT_MIGRATION_FILE)
	fi
}

# Save the current migration step.
# TODO: This should be stored in the db itself.
function save_current_migration_step {
	local migration="$1"
	echo "$migration" > "$CURRENT_MIGRATION_FILE"
}

# **REQUIRED**: Execute the migration step itself.
# It will be passed the extract from the migration file.
function execute_migration_step {
	local query="$1"

	mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" "$DB_NAME" <<< $query
	return $?
}
