#!/bin/bash
source 'audio.sh';
cmd=$1 && shift;
case "$cmd" in
    "bluetooth__reset")
        bluetooth__reset "$@";
        ;;
    "bluetooth__toggle")
        bluetooth__toggle "$@";
        ;;
esac;