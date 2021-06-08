
# $1 = method (null/'push'/'pull') , $2 = dry (null/'dry') , $@ = files
sync()
{
  method=$1
  dry=$2
  shift 2

  check_paths "$@" || return $?

  get_server || { echo "Server not configured on this instance" >&2 && return 1; }
  get_ignores

  # init and check local
  init_local || return $?

  # init, check, and lock server
  init_server || {
    ret=$?
    unlock_local
    return $ret
  }

  tdir=$(tmpdir)
  mkdir -p "$tdir"


  local_full_list  > "$tdir/local_full"
  local_hash_list  > "$tdir/local_hash"
  server_both_list | tee >(
      head -z -n1  | tr -d '\0' | sort > "$tdir/server_full"
  ) | tail -z -n1 | sort > "$tdir/server_hash"

  # get changed on both sides
  local_newer=$( list_diff "$tdir/local_hash"  "$@") || { rm -rf "$tdir" ; unlock_all ; return 1; }
  server_newer=$(list_diff "$tdir/server_hash" "$@") || { rm -rf "$tdir" ; unlock_all ; return 1; }
  # get deleted on both sides
  deleted_local=$( get_deleted "$tdir/local_full"  "$@") || { rm -rf "$tdir" ; unlock_all ; return 1; }
  deleted_server=$(get_deleted "$tdir/server_full" "$@") || { rm -rf "$tdir" ; unlock_all ; return 1; }

  # get collisions
  collisions=$(printf "%s\n%s\n" "$local_newer" "$server_newer" | sort | uniq -d)
  [ -n "$collisions" ] && [ "$method" != push ] && [ "$method" != pull ] && {
    echo "-- There are file collisions" >&2
    echo "$collisions"
    rm -rf "$tdir"
    unlock_all
    return 100
  }

  # remove collisions from opposing method
  [ -n "$collisions" ] && {
    if [ "$method" = "pull" ]
    then
      local_newer=$(printf "%s\n%s\n" "$collisions" "$local_newer" | sort | uniq -u)
    else
      server_newer=$(printf "%s\n%s\n" "$collisions" "$server_newer" | sort | uniq -u)
    fi
  }

  if [ -n "$local_newer" ] || [ -n "$server_newer" ] || [ -n "$deleted_local" ] || [ -n "$deleted_server" ]
  then
    # operations
    if [ "$method" = "pull" ]
    then
      [ -n "$server_newer" ] && echo "$server_newer" | recieve "$dry"
      [ -n "$local_newer"  ] && echo "$local_newer"  | send    "$dry"
    else
      [ -n "$local_newer"  ] && echo "$local_newer"  | send    "$dry"
      [ -n "$server_newer" ] && echo "$server_newer" | recieve "$dry"
    fi

    # delete has no impact on timestamps
    [ -n "$deleted_local"  ] && echo "$deleted_local"  | delete_server "$dry"
    [ -n "$deleted_server" ] && echo "$deleted_server" | delete_local  "$dry"

    # real run
    [ "$dry" != "dry" ] && {
      # update lists
      write_lists
    }
  fi

  rm -rf "$tdir"

  unlock_all
}
