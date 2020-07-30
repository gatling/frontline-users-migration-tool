#!/bin/bash

set -e
dir=$(dirname "$0")

. "$dir/script/util.sh" --source-only
source "$dir/environment.conf"


check_cassandra_env_variables 

# Replace dump.csv first column (username) by username on same line in $dir/data/usernames.csv

echo "Updating $dir/data/dump.csv with $dir/data/usernames.csv, result will be in $dir/data/migrated.csv"
awk -F, 'NR==FNR{usernames[FNR]=$1}NR!=FNR{print usernames[FNR]FS$2FS$3FS$4FS$5FS$6}' $dir/data/usernames.csv $dir/data/dump.csv > $dir/data/migrated.csv
chmod 660 "$dir/data/migrated.csv"

# Check no duplication

echo "Checking duplicates in $dir/data/usernames.csv..."
duplicates=$(uniq -d "$dir/data/usernames.csv")
if [ -z $duplicates ] 
then
  echo "No duplicate found."
else
  echo "Duplicate usernames found:"
  echo $duplicates
  echo "Exiting."
  exit 2
fi

# Create migrated csv

awk -F, 'NR==FNR{usernames[FNR]=$1}NR!=FNR{columns="";for (i=2; i <= NF; i++) columns = columns FS $i; print usernames[FNR]columns}' "$dir/data/usernames.csv" "$dir/data/dump.csv" > "$dir/data/migrated.csv" # Replace usernames in $dir/data/dump.csv
echo "Dump with updated usernames under migrated.csv"


# Drop users table content
if [ -f "$dir/data/dump.csv" ]; then
    echo "Database dump at $dir/data/dump.csv"
else
    echo "Database dump doesn't exist. ($dir/data/dump.csv)"
fi
echo "Users table content is going to be dropped..."
read -r -p "Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        echo "Drop users table."
        cqlsh_request "TRUNCATE $FRONTLINE_CASSANDRA_KEYSPACE.users"
        echo ""
        ;;
    *)
        exit 0
        ;;
esac

## Insert migrated users

echo "Inserting migrated users (in $dir/data/migrated.csv)"
cqlsh_request "COPY $FRONTLINE_CASSANDRA_KEYSPACE.users FROM '$dir/data/migrated.csv'"
