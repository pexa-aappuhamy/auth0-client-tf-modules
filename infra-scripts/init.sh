#! /usr/bin/env bash

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Please provide two arguments: the directory, and the environment." > /dev/stderr
  exit 1
fi

DIRECTORY=$1
ENVIRONMENT=$2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# echo "machine $ARTIFACTORY_DOMAIN login $ARTIFACTORY_USERNAME password $TF_VAR_artifactory_token" > "$HOME/.netrc"
"$SCRIPT_DIR/run-terraform.sh" init "$DIRECTORY" "$ENVIRONMENT"
