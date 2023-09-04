#!/usr/bin/env bash

# Helper script to start a Python web server for the current working directory.

set -euo pipefail

export SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
source "${SCRIPT_DIR}/web_server.sh"

# Check if the server is not running.
if [[ -z "${WEB_SERVER_PID}" ]]; then
  DIR=${@:-.}
  OUTPUT_TO_FILE=">~/Desktop/http_server_log.txt 2>&1"
  OUTPUT_TO_NULL='>/dev/null 2>&1'
  # Start localhost Python web server in the background.
  command="nohup python3 -m ${WEB_SERVER_CMD} -d \"${DIR}\" ${OUTPUT_TO_NULL} &"
  eval ${command}
  echo "Started web server (${WEB_SERVER_CMD}) with pid: $(get_server_pid)."
else
  echo "Web server (${WEB_SERVER_CMD}) already running with pid: ${WEB_SERVER_PID}."
fi

open http://localhost
