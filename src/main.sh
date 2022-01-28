#!/bin/lxsh

set -e

[ "$DEBUG" = true ] && set -x

%include config.sh options.sh *.sh

arg=$1
shift 1

# actions
case $arg in
  server) setup_server "$@" ;;
  run)     sync ""   ""  "$@" ;;
  pull)    sync pull ""  "$@" ;;
  push)    sync push ""  "$@" ;;
  dry)     sync ""   dry "$@" ;;
  drypush) sync push dry "$@" ;;
  drypull) sync pull dry "$@" ;;
  forcepush) forcepush ;;
  forcepull) forcepull ;;
  *) usage && exit 1 ;;
esac
