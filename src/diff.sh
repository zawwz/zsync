
## DIFFERENCES

# find changes from list
# $1 = list file , $@ = targets
# requisite: file contains both hash and filename and is sorted
list_diff()
{
  file=$1
  shift 1
  [ ! -f "$tree_hash" ] && { cut -c34- "$file" ; return 0; }
  diff --old-line-format="" --unchanged-line-format="" "$tree_hash" "$file" | cut -c34- | merge "$@"
}

# find deleted from list
# $1 = list file , $@ = targets
# requisite: file contains only filename and is sorted
get_deleted()
{
  file=$1
  shift 1
  [ ! -f "$tree_full" ] && return 0
  diff --new-line-format="" --unchanged-line-format="" "$tree_full" "$file" | reduce_list | grep -vE "$ignores" | merge "$@"
}
