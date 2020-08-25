#!/bin/bash

set -e
dir=$(dirname "$0")
mkdir -p "$dir/data"

. "$dir/script/util.sh" --source-only
source "$dir/environment.conf"

check_cassandra_env_variables 

echo ""
echo "Copying $FRONTLINE_CASSANDRA_KEYSPACE.users table content to $dir/data/dump.csv"
cqlsh_request "COPY $FRONTLINE_CASSANDRA_KEYSPACE.users TO '$dir/data/dump.csv'"
chmod 440 "$dir/data/dump.csv"

echo ""
echo "Extracting usernames from dump.csv to usernames.csv"
awk -F, '{ print $1 }' "$dir/data/dump.csv" > "$dir/data/usernames.csv"
chmod 660 "$dir/data/usernames.csv"

echo "Update usernames in $dir/data/usernames.csv, then run the migration command (migrate-usernames.sh)."
