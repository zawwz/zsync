
## generic tools

# $@ = paths
check_paths()
{
  for N
  do
    echo "$N" | grep "^/" && echo "Path cannot start with /" >&2 && return 1
    echo "$N" | grep -Fw ".." && echo "Path cannot contain .." >&2 && return 1
  done
  return 0
}

tmpdir() {
  echo "$tmpdir/zsync_$(tr -dc '[:alnum:]' </dev/urandom | head -c20)"
}

# $1 = code , $@ = arguments
ssh_exec() {
  code=$1
  shift 1
  ssh "$raddr" sh -c "$(/usr/bin/printf "%q " "$code")" sh "$(/usr/bin/printf "%q " "$@")"
}
