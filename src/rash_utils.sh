#!/usr/bin/env bash



# Colors and output
# -----------------

# Some basic ANSI color definitions.
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1;33m"
COLOR_ERROR="\033[31m"

# Small useful functions to output a colored string.
# Especially useful when used like this:
#     echo Whatever, $(bold man)!
#
# FIXME: Colors should not be used unless we're sure
# that the terminal supports color escapes (eg, scripts).
function bold {
	echo -e ${COLOR_BOLD}$@${COLOR_RESET}
}
function error {
	echo -e ${COLOR_ERROR}$@${COLOR_RESET}
}



# Lists
# -----

# Returns the first element in a list.
#     first (a b c)
#     > a
function first {
	local list=("$@")
	echo ${list[0]}
}

# Returns the last element in a list.
#     last_in_list (a b c)
#     > c
function last {
	local list=("$@")
	local count=${#list[@]}
	echo ${list[ (( $count -1 )) ]}
}



# Numerics
# --------

# Formats a number in four digits.
#     format 24
#     > 0024
function format {
	local num=$1
	printf "%04d" $num
}

# Interpretes a number in base 10.
#     parse 024
#     > 24
function parse {
	local num=$1
	echo $(( 10#$num ))
}

# Returns the digits at the front of a string
#     numeric 0001_whatever
#     > 0001
function numeric {
	local str=$1
	echo $(expr "$str" : '\(^[0-9]*\)')
}

# Returns the next or previous ordinal number.
# It's pretty basic, but it's used in the migration steps.
#     ordinal up 1
#     > 2
#     ordinal down 1
#     > 0
function ordinal {
	local dir="$1"
	local num=$2

	if [[ $dir == 'up' ]]; then
		echo $(( $num +1 ))
	elif [[ $dir == 'down' ]]; then
		echo $(( $num -1 ))
	fi
}

# Returns up or down based on the comparison
# between two numbers.
#     direction 0001 0003
#     > up
#     direction 0003 0002
#     > down
function direction {
	local a=$1
	local b=$2

	if [[ $a < $b ]]; then
		echo up
	elif [[ $a > $b ]]; then
		echo down
	fi
}



# Text
# ----

# Extract part of a file between two tags.
# Just remember that this will be passed to awk,
# so remember to escape the tag strings.
#     extract "0001.sql" '<up>' '<\/up>'
#     > ...extracted snippet...
function extract {
	local file="$1"
	local open_tag="$2"
	local close_tag="$3"

	awk "/${open_tag}/,/${close_tag}/" "$file" | sed '1d;$d'
}



# Execution
# ---------

# Wraps a function, catches the output and the exit code.
# If the code is non-zero, it prints the output as error and dies.
#     catch_errors command args
#     > Something went wrong!
function catch_errors {
	local cmd="$@"
	local output; output=$( $cmd 2>&1 )
	local exit_code=$?

	if [[ $exit_code -ne 0 ]]; then
		echo $(error $output)
		exit $exit_code
	fi
}