#! /usr/bin/env bash

set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Please provide three arguments: the Terraform operation to run, the directory, and the environment." >/dev/stderr
  exit 1
fi

TERRAFORM_OPERATION=$1
DIRECTORY="${2/%\/}" # This incantation removes trailing slashes from the value. (eg. "component/thing/" becomes "component/thing")
ENVIRONMENT=$3
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RESOLVED_DIRECTORY="$ROOT_DIR/$DIRECTORY"
COMPONENT_DIRECTORY="$ROOT_DIR/${DIRECTORY%%/*}"
ENVIRONMENT_FILE="$COMPONENT_DIRECTORY/env-config/$ENVIRONMENT.json"
VARIABLES_FILE="$RESOLVED_DIRECTORY/tf-vars/$ENVIRONMENT.tfvars"
PLAN_FILE="$RESOLVED_DIRECTORY/$ENVIRONMENT.plan"
LAST_INIT_FILE="$RESOLVED_DIRECTORY/.terraform/.last_terraform_init"

TERRAFORM_PARALLELISM=40

function main() {
  checkDirectoryExists
  checkConfigExists

  local ACCOUNT_ID REGION
  ACCOUNT_ID=$(getAWSAccountID)
  REGION=$(getAWSRegion)

  # validateAccountIDAndRegionMatchCredentials "$ACCOUNT_ID" "$REGION"
  showConfigurationSummary "$ACCOUNT_ID" "$REGION"

  runTerraform "$ACCOUNT_ID" "$REGION"
}

function checkDirectoryExists() {
  if [ ! -d "$RESOLVED_DIRECTORY" ]; then
    echo "The directory '$DIRECTORY' does not exist." >/dev/stderr
    exit 1
  fi
}

function checkConfigExists() {
  if [ ! -f "$ENVIRONMENT_FILE" ]; then
    echo "Environment definition file for $ENVIRONMENT environment '$ENVIRONMENT_FILE' does not exist." >/dev/stderr
    exit 1
  fi

  if [ ! -f "$VARIABLES_FILE" ]; then
    echo "Warning: variables file for $ENVIRONMENT environment '$VARIABLES_FILE' does not exist, so it will not be passed to Terraform." >/dev/stderr
    echo
  fi
}

function getAWSAccountID() {
  jq -r -e '.accountID' "$ENVIRONMENT_FILE" || { echo "'$ENVIRONMENT_FILE' does not contain a valid AWS account ID." >/dev/stderr; exit 1; }
}

function getAWSRegion() {
  jq -r -e '.region' "$ENVIRONMENT_FILE" || { echo "'$ENVIRONMENT_FILE' does not contain a valid AWS region." >/dev/stderr; exit 1; }
}

function validateAccountIDAndRegionMatchCredentials() {
  local ACCOUNT_ID=$1
  local REGION=$2

  if [ "$REGION" != "$AWS_REGION" ]; then
    echo "Region '$REGION' in '$ENVIRONMENT_FILE' does not match region set in AWS_REGION environment variable ($AWS_REGION). Are you using the correct credentials?" >/dev/stderr
    exit 1
  fi

  local AWS_REPORTED_ACCOUNT_ID
  AWS_REPORTED_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

  if [ "$ACCOUNT_ID" != "$AWS_REPORTED_ACCOUNT_ID" ]; then
    echo "Account ID '$ACCOUNT_ID' in '$ENVIRONMENT_FILE' does not match account ID of current AWS credentials ($AWS_REPORTED_ACCOUNT_ID). Are you using the correct credentials?" >/dev/stderr
    exit 1
  fi
}

function showConfigurationSummary() {
  local ACCOUNT_ID=$1
  local REGION=$2

  echo "Configuration summary:"
  echo "  Directory: $DIRECTORY"
  echo "  Environment: $ENVIRONMENT"
  echo "  Environment definition file: $ENVIRONMENT_FILE"
  echo "  AWS account ID: $ACCOUNT_ID"
  echo "  AWS region: $REGION"

  if [ -f "$VARIABLES_FILE" ]; then
    echo "  Terraform variables file: $VARIABLES_FILE"
  else
    echo "  Terraform variables file: (not found, checked for $VARIABLES_FILE)"
  fi

  echo
}

function runTerraform() {
  local ACCOUNT_ID=$1
  local REGION=$2

  {
    cd "$RESOLVED_DIRECTORY"

    if needToInitTerraform || [[ "$TERRAFORM_OPERATION" == "init" ]]; then
      initTerraform "$ACCOUNT_ID" "$REGION"
    fi

    case $TERRAFORM_OPERATION in
    init)
      # Nothing more to do - covered above.
      ;;

    plan)
      planTerraform
      ;;

    apply)
      applyTerraform
      ;;

    destroy)
      destroyTerraform
      ;;

    check)
      checkTerraform
      ;;

    *)
      echo "Unknown operation '$TERRAFORM_OPERATION'." >/dev/stderr
      exit 1
      ;;
    esac
  }
}

# The logic here isn't perfect - it won't catch situations where we've added or changed
# modules or providers, but Terraform will catch those. We just want to make sure we
# never end up applying changes to the wrong environment.
function needToInitTerraform() {
  if [ ! -f "$LAST_INIT_FILE" ]; then
    return 0
  fi

  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(currentInitState)

  local CURRENT_CONTENT
  CURRENT_CONTENT=$(cat "$LAST_INIT_FILE")

  if [[ "$CURRENT_CONTENT" != "$EXPECTED_CONTENT" ]]; then
    return 0
  fi

  return 1
}

function initTerraform() {
  local ACCOUNT_ID=$1
  local REGION=$2

  rm -f "$LAST_INIT_FILE"

  terraform init -reconfigure -input=false
    # -backend-config=region="$REGION" \
    # -backend-config=key="$DIRECTORY/$ENVIRONMENT-terraform.tfstate" \
    # -backend-config=bucket="pexa-terraform-state-$REGION-$ACCOUNT_ID" \
    # -backend-config=dynamodb_table="pexa-terraform-state-locking-$REGION-$ACCOUNT_ID"

  currentInitState >"$LAST_INIT_FILE"
}

function currentInitState() {
  cat <<EOF
    $DIRECTORY
    $ENVIRONMENT
    $REGION
    $ACCOUNT_ID
EOF
}

function planTerraform() {
  runTerraformWithVariables terraform plan -input=false -out="$PLAN_FILE" -parallelism="$TERRAFORM_PARALLELISM"
}

function checkTerraform() {
  STATUS=0
  runTerraformWithVariables terraform plan -input=false -detailed-exitcode -parallelism="$TERRAFORM_PARALLELISM" || STATUS=$?

  case $STATUS in
  0)
    echo "Deployed infrastructure matches desired state." >/dev/stderr
    ;;

  1)
    echo "Error occurred during check. See above output from Terraform for details." >/dev/stderr
    ;;

  2)
    echo "Deployed infrastructure does not match desired state. See above output from Terraform for details." >/dev/stderr
    ;;

  *)
    echo "Unknown exit code $STATUS from Terraform. See above output from Terraform for details." >/dev/stderr
    ;;
  esac

  exit $STATUS
}

function applyTerraform() {
  terraform apply -input=false -parallelism="$TERRAFORM_PARALLELISM" "$PLAN_FILE"
}

function destroyTerraform() {
  runTerraformWithVariables terraform destroy -input=false -parallelism="$TERRAFORM_PARALLELISM"
}

function runTerraformWithVariables() {
  local VARIABLES_FILE_ARG=()

  if [ -f "$VARIABLES_FILE" ]; then
    VARIABLES_FILE_ARG=("-var-file=$VARIABLES_FILE")
  fi

  "$@" \
    -var environment="$ENVIRONMENT" \
    -var-file="../../tf-vars/$ENVIRONMENT.tfvars" \
    "${VARIABLES_FILE_ARG[@]}" \
    
}

main
