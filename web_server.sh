#!/usr/bin/env bash

# Helper script to start/stop a Python web server for the current working directory.

set -euo pipefail

DEFAULT_WEB_PORT=80

escape_string_for_regex() {
  echo "$@" | sed -e 's/\(-.\)/\\\1/g'
}

get_server_pid() {
  pgrep -f -u $(whoami) "$(escape_string_for_regex ${WEB_SERVER_CMD}) " || echo ""
}

abspath() {
  echo $(cd "${@}"; pwd -P)
}

start_web_server() {
  # Check if the server is not running.
  if [[ -z "${WEB_SERVER_PID}" ]]; then
    DIR=${@:-.}
    OUTPUT_TO_NULL='>/dev/null 2>&1'
    # Start localhost Python web server in the background.
    command="nohup python3 -m ${WEB_SERVER_CMD} -d \"$(abspath ${DIR})\" ${OUTPUT_TO_NULL} &"
    eval ${command}
    echo "Started web server (${WEB_SERVER_CMD}) with pid: $(get_server_pid)"
  else
    echo "Web server (${WEB_SERVER_CMD}) already running with pid: ${WEB_SERVER_PID}"
  fi

  if [[ ${WEB_SERVER_PORT} == ${DEFAULT_WEB_PORT} ]]; then
    open http://localhost
  else
    open http://localhost:${WEB_SERVER_PORT}
  fi
}

stop_web_server() {
  # Check if the server is running.
  if [[ ! -z "${WEB_SERVER_PID}" ]]; then
    kill -9 ${WEB_SERVER_PID}
    echo "Stopped web server (${WEB_SERVER_CMD}) with pid: ${WEB_SERVER_PID}."
  else
    echo "Web server (${WEB_SERVER_CMD}) not running."
  fi
}

usage() {
  echo "Usage: $(basename $0) [-s] [PORT:${DEFAULT_WEB_PORT}]" 1>&2
  exit 1
}

STOP_SERVER=0
ARGS=()
while [ $# -gt 0 ]; do
  unset OPTIND
  unset OPTARG
  while getopts "sh" opt; do
    case ${opt} in
      s)
        STOP_SERVER=1
        ;;
      h | * | :) # Display help.
        usage
        ;;
    esac
  done
  shift $((OPTIND-1))
  if [[ ${1-''} ]]; then
    ARGS+=("${1-''}")
    shift
  fi
done

WEB_SERVER_PORT=${ARGS[0]-${DEFAULT_WEB_PORT}}
WEB_SERVER_CMD="http.server ${WEB_SERVER_PORT}"
WEB_SERVER_PID=$(get_server_pid)

if [[ ${STOP_SERVER} != 0 ]]; then
  stop_web_server
else
  start_web_server
fi
