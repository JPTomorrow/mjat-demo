#!/bin/sh
echo -ne '\033c\033]0;MJAT Demo\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/mjat-demo-server.x86_64" "$@"
