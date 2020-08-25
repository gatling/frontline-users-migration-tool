function check_cassandra_env_variables() {
  local invalid
  invalid=false
  if [ -z $FRONTLINE_CASSANDRA_HOST ]
  then
    invalid=true
    echo "variable FRONTLINE_CASSANDRA_HOST not defined";
  fi

  if [ -z $FRONTLINE_CASSANDRA_PORT ]
  then
    invalid=true
    echo "variable FRONTLINE_CASSANDRA_PORT not defined";
  fi

  if [ -z $FRONTLINE_CASSANDRA_KEYSPACE ]
  then
    invalid=true
    echo "variable FRONTLINE_CASSANDRA_KEYSPACE not defined";
  fi

  if [ "$invalid" = true ]
  then
    echo "Exiting."
    exit 1;
  fi
}

function cqlsh_request() {
  cqlsh_command="cqlsh $FRONTLINE_CASSANDRA_HOST $FRONTLINE_CASSANDRA_PORT"
  if [ ! -z $FRONTLINE_CASSANDRA_USERNAME ]
  then
    cqlsh_command="$cqlsh_command -u $FRONTLINE_CASSANDRA_USERNAME"
  fi

  if [ ! -z $FRONTLINE_CASSANDRA_PASSWORD ]
  then
    cqlsh_command="$cqlsh_command -p $FRONTLINE_CASSANDRA_PASSWORD"
  fi
  cqlsh_command="$cqlsh_command -e \"$1\""
  echo $cqlsh_command
  eval $cqlsh_command
}
