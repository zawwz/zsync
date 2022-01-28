
## LIST

local_hash_list()
{
  { ( set -e
  find . -type f ! -regex "^./$syncdir/.*" | sed 's|^./||g' | grep -vE "$ignores" | tr '\n' '\0' | xargs -0 md5sum | cut -c1-33,35-
  find . -type l | sed 's|^./||g' | while read -r ln
  do
    find "$ln" -maxdepth 0 -printf '%l' | md5sum | sed "s|-|$ln|g"
  done | cut -c1-33,35- | grep -vE "$ignores"
  ) || return $?; } | sort
}

server_hash_list()
{
  ssh_exec '#LXSH_PARSE_MINIFY
    set -e
    cd "$1"
    find . -type f ! -regex "^./$2/.*" | sed "s|^./||g" | grep -vE "$3" | tr "\n" "\0" | xargs -0 md5sum | cut -c1-33,35-
    find . -type l | sed "s|^./||g" | while read -r ln
    do
      find "$ln" -maxdepth 0 -printf "%l" | md5sum | sed "s|-|$ln|g"
    done | cut -c1-33,35- | grep -vE "$3"
  ' "$rdir" "$syncdir" "$ignores" | sort
}

local_full_list() {
  find . -mindepth 1 ! -regex "^./$syncdir\$" ! -regex "^./$syncdir/.*" | sed 's|^./||g' | grep -vE "$ignores" | sort
}

local_file_list() {
  find . -mindepth 1 ! -type d ! -regex "^./$syncdir\$" ! -regex "^./$syncdir/.*" | sed 's|^./||g' | grep -vE "$ignores" | sort
}

server_full_list() {
  ssh_exec '#LXSH_PARSE_MINIFY
    set -e
    cd "$1"
    find . -mindepth 1 ! -regex "^./$2\$" ! -regex "^./$2/.*" | sed "s|^./||g" | grep -vE "$3"
  ' "$rdir" "$syncdir" "$ignores" | sort
}

server_file_list() {
  ssh_exec '#LXSH_PARSE_MINIFY
    set -e
    cd "$1"
    find . -mindepth 1 ! -type d ! -regex "^./$2\$" ! -regex "^./$2/.*" | sed "s|^./||g" | grep -vE "$3"
  ' "$rdir" "$syncdir" "$ignores" | sort
}

server_both_list() {
  ssh_exec '#LXSH_PARSE_MINIFY
    set -e
    cd "$1"
    find . -mindepth 1 ! -regex "^./$2\$" ! -regex "^./$2/.*" | sed "s|^./||g" | grep -vE "$3"
    printf "\0"
    {
      find . -type f ! -regex "^./$2/.*" | sed "s|^./||g" | tr "\n" "\0" | xargs -0 md5sum | cut -c1-33,35- | grep -vE "$3"
      find . -type l | sed "s|^./||g" | while read -r ln
      do
        find "$ln" -maxdepth 0 -printf "%l" | md5sum | sed "s|-|$ln|g"
      done | cut -c1-33,35- | grep -vE "$3"
    }
  ' "$rdir" "$syncdir" "$ignores"
}

write_lists()
{
  local_full_list > "$tree_full"
  local_hash_list > "$tree_hash"
}
