
## TRANSACTIONS

# read list from stdin
# $1 = dry mode
send() {
  if [ "$1" = "dry" ]
  then
    echo "* files to send"
    cat
  else
    printf '* '
    rsync $rsync_opts --files-from=- --exclude=".zsync" -e ssh "$(pwd)" "$raddr:$rdir" || return $?
  fi
}

# read list from stdin
# $1 = dry mode
recieve() {
  if [ "$1" = "dry" ]
  then
    echo "* files to recieve"
    cat
  else
    printf '* '
    rsync $rsync_opts --files-from=- -e ssh "$raddr:$rdir" "$(pwd)" || return $?
  fi
}


# read list from stdin
# $1 = dry mode
delete_server() {
  if [ "$1" = "dry" ]
  then
    echo "* deleted to send"
    cat
  else
    echo "* sending deleted"
    ssh_exec '# LXSH_PARSE_MINIFY
      cd "$1" || exit 1
      shift 1
      trashutil="gio trash"
      which trash-put >/dev/null 2>&1 && trashutil=trash-put
      for N
      do
        $trashutil "$N" && echo "$N" || exit $?
      done
    ' "$rdir" $(xargs -d "\n" /usr/bin/printf "%q ")
  fi
}
# read delete from stdin
# $1 = dry mode
delete_local() {
  if [ "$1" = "dry" ]
  then
    echo "* deleted to recieve"
    cat
  else
    echo "* recieving deleted"
    trashutil='gio trash'
    which trash-put >/dev/null 2>&1 && trashutil=trash-put
    while read -r ln
    do
      $trashutil "$ln" && echo "$ln" || return $?
    done
  fi
}

forcepull()
{
  local ret=0
  get_server  || return $?
  init_local  || return $?
  init_server || { unlock_local ; return $?; }
  rsync $rsync_opts -r --delete -e ssh "$raddr:$rdir" "$(pwd)/." || ret=$?
  unlock_all
  write_lists
  return $ret
}

forcepush()
{
  local ret=0
  get_server  || return $?
  init_local  || return $?
  init_server || { unlock_local ; return $?; }
  rsync $rsync_opts -r --delete -e ssh "$(pwd)/." "$raddr:$rdir" || ret=$?
  unlock_all
  write_lists
  return $ret
}
