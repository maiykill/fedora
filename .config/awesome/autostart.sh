#!/usr/bin/env dash

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

run nm-applet
run copyq
