# Frontline Users Migration Tool

FrontLine **1.12** introduces **OIDC support**.

Users wanting to migrate might have issues because LDAP usernames are case insensitive so we store them in minor case.
On the contrary, OIDC usernames are case sensitive.

As a result: usernames might no longer match.

This tool help you rename users to match the proper case, 
or even change the username to a new unique mapped attribute needed with OIDC support enabled.

> **WARNING**: This tool make a dump of the users table, 
> please double check dump content before performing the migration.
> A backup of the database would be preferred (for single-node, by copying /var/lib/cassandra).

# Prerequisites
 
  * Access to the Cassandra cluster
  * bash
  *  `cqlsh` and `awk` commands in path

## How to use

**FrontLine** need to be **stopped**.
Update `environment.conf` with your cassandra host and port. 
Optionally, you can specify username and password.


Retrieve `$dir/data/username.csv` file by running the following command in a terminal:

```
$ cd frontline-users-migration-tool
$ ./fetch-usernames.sh
```

A dump of the users table will be created under `$dir/data/dump.csv`, make sure it is valid.
It must contains all users, one per row, following the format: 
`username,email,firstname,lastname,hashed_password,role_by_team`

(From LDAP users, the email, firstname, lastname and hashed_password fields will be empty)


Then, update usernames in `$dir/data/usernames.csv` to desired case-sensitive usernames. (one username per row)

When you're ready, start the migration by running the following command in a terminal:

```
$ ./migrate-usernames.sh
```

`$dir/data/migrated.csv` contains the new users table content, and your database has been updated.

## Output example

##### Step 1
 ```
$ cd frontline-users-migration-tool
$ ./fetch-usernames.sh

Copying gatling.users table content to dump.csv
Using 11 child processes

Starting copy of gatling.users with columns [username, email, firstname, lastname, password, role_by_team].
Processed: 1 rows; Rate:       7 rows/s; Avg. rate:       7 rows/s
1 rows exported to 1 files in 0.154 seconds.

Extracting usernames from dump.csv to usernames.csv
Update usernames in $dir/data/usernames.csv, then run the migration command (migrate-usernames.sh).
 ```

##### Step 2

Update usernames in `$dir/data/usernames.csv`

##### Step 3

```
$ ./migrate-usernames.sh

Updating dump.csv with usernames.csv, result will be in migrated.csv
Checking duplicates in usernames.csv...
No duplicate found.
migrate-users-perform.sh: line 28: $dir/data/migrated.csv: Permission denied
Dump with updated usernames under migrated.csv
 does not exist.
Users table content is going to be dropped...

Continue? [y/N] 
$ y
Drop users table.

Inserting migrated users (in migrated.csv)
Using 11 child processes

Starting copy of gatling.users with columns [username, email, firstname, lastname, password, role_by_team].
Processed: 1 rows; Rate:       1 rows/s; Avg. rate:       2 rows/s
1 rows imported from 1 files in 0.441 seconds (0 skipped).

```

## Errors codes

`1` - Cassandra **host** or **port** not specified

`2` - Duplicate username in `$dir/data/usernames.csv`