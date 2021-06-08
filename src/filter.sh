
## FILTERS

run_ignore() {
  [ -n "$ignores" ] && grep -vE "$ignores" "$@"
}

# $1 = regex , $@ = args
grep_after_sum()
{
  reg=$1
  shift 1
  grep --color=never -E "^[0-9a-f]{32} $reg" "$@"
}

# $@ = match these
merge()
{
  if [ $# -gt 0 ]
  then
    re="$1"
    shift 1
    for N
    do
      re="$re|$N"
    done
    grep -E "^($re)"
    return 0
  else # don't change input
    cat
  fi
}

# reduce list to only subsets
# kind of like "uniq" but matches lines that are supersets, only outputting the subset
# needs a sorted list in input
# $1 = separator for subset-superset (default="/")
reduce_list()
{
  awk 'BEGIN{ FS="\n"; RS="\0" ; i = 0 } {
      i=1
      while(i<=NF)
      {
        print $i
        val=$i "'"${1-"/"}"'"
        i++;
        while(substr($i, 0, length(val)) == val)
        {
          i++;
        }
      }
    }
  '
}
