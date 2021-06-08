
# usage
fname=$(basename "$0")
usage()
{
  echo "$fname [operation]

Operations:
  server <server>     Setup sync on current folder with server target
  run [file...]       Run sync with server
  push [file...]      Regular run but push all conflicts
  pull [file...]      Regular run but pull all conflicts
  dry [file...]       Run a simulated sync but do not perform any action
  drypush [file...]   Dry run as push
  drypull [file...]   Dry run as pull
  forcepush           Push by force the entire tree. Will replace and delete remote files
  forcepull           Pull by force the entire tree. Will replace and delete local files"
}

# options
unset arg_c
while getopts ":hC:" opt;
do
  case $opt in
    C)
      [ -z "$OPTARG" ] && echo "Option -C requires an argument" >&2 && exit 1
      arg_c="$OPTARG"
      ;;
    h) usage && exit 1 ;;
    *) echo "Unknown option: $OPTARG" >&2 && usage && exit 1 ;;
  esac
done
shift $((OPTIND-1))

# raddr=zawz@zawz.net
# rdir=sync/tmp
[ -f "$server_file" ] && get_server

[ -n "$arg_c" ] && { cd "$arg_c" || exit $?; }   # -C opt

[ $# -lt 1 ] && usage && exit 1

which rsync >/dev/null || { echo "rsync not installed" >&2 && exit 1; }
/usr/bin/printf %q >/dev/null || { echo "printf does not support %q" >&2 && exit 1; }
