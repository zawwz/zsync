
# globals
syncdir=".zsync"
lock_file=".zsync/lock"
ignore_file=".zsync/ignore"
tree_full=".zsync/tree_full"
tree_hash=".zsync/tree_hash"
config_file=".zsync/config"

# NO -t OPTION FOR RSYNC
rsync_opts='-rvlpE'

tmpdir=${TMPDIR-/tmp}

## CONFIG

init_config() {
  mkdir -p "$syncdir" || return 2
  which rsync >/dev/null 2>&1 || { echo rsync not installed on server >&2 ; return 3; }
  touch "$config_file" || return 5
}

get_server() {
  [ ! -f "$config_file" ] && return 1
  servconf=$(sed 's|^[ \t]*||g' "$config_file" | grep -E '^server[ \t]' | sed 's|^server[ \t]*||g' | tail -n1)
  raddr=$(echo "$servconf" | cut -d ':' -f1)
  rdir=$(echo "$servconf" | cut -d ':' -f2-)
}

# $1 = server arg
setup_server()
{
  init_config || return $?
  [ -z "$1" ] && echo "$fname server user@host:path" && return 1
  sed -i '/^[ \t]*server[ \t]/d' "$config_file"
  echo "server $1" >> "$config_file"
}

ignores='\.zsync'
get_ignores() {
  if [ -f "$ignore_file" ]
  then
    ignores="($(tr '\n' '|' < "$ignore_file"))"
  else
    ignores='(^$)'
  fi
  ignores=$(echo "$ignores" | sed ' s/|)/)/g ; s/^()$/^$/g ')
  [ -n "$ignores" ] || ignores='\.zsync'
}
