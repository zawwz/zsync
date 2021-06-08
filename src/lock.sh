
## LOCK

lock_local() { touch "$lock_file"; }
unlock_local() { rm "$lock_file"; }
lock_server() {
  ssh_exec 'touch "$1"' "$rdir/$lock_file";
}
unlock_server() {
  ssh_exec 'rm "$1"' "$rdir/$lock_file";
}
lock_all() { lock_local && lock_server ; }
unlock_all() { ret=0; unlock_local || ret=$? ; unlock_server || ret=$?; return $ret ; }

local_lock_check() {
  [ ! -f "$lock_file" ] || { echo "Local sync locked, wait for sync completion" >&2 && return 1; }
}
server_lock_check() {
  ssh_exec '
    cd "$1" || return 0
    [ ! -f "$2" ]
  ' "$rdir" "$lock_file" || { echo "Server sync locked, wait for sync completion" >&2 && return 1; }
}

# init
init_local() {
  mkdir -p "$syncdir" || return 2
  which rsync >/dev/null 2>&1 || { echo rsync not installed on server >&2 ; return 3; }
  local_lock_check || return 4
  touch "$lock_file" || return 5
}

init_server() {
  ssh_exec '
    cd "$1" || exit 1
    mkdir -p "$2" || exit 2
    which rsync >/dev/null 2>&1 || { echo rsync not installed on server >&2 ; exit 3; }
    [ -f "$2" ] && { echo Server sync locked, wait for sync completion ; exit 4; }
    touch "$3" || exit 5
  ' "$rdir" "$syncdir" "$lock_file"
}
