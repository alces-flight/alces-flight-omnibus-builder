#==============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of Alces Flight Omnibus Builder.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# This project is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with this project. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Alces Flight Omnibus Builder, please visit:
# https://github.com/alces-flight/alces-flight-omnibus-builder
#===============================================================================

usage() {
    local prog
    prog="flight gather export"
    cat <<USAGE
Usage: ${prog} [--help] [--dry-run] ASSET_NAME...
Export inventory data to Alces Flight Center
  --help    Display this help text
  --dry-run Output the asset sheets to a directory, instead of Alces Flight Center
USAGE
}

# Define the path to the flight bin file
echo ${flight_ROOT:?Has not been set!} >/dev/null
FLIGHT="$flight_ROOT/bin/flight"

# Parse the help and dry-run flags
PARAMS=""
DRY_RUN=""
while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      exit
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

# Error if no assets have been provided
if [ $# -eq 0 ]; then
  echo 'Please provide at least one asset!' >&2
  usage
  exit 1
fi

# Ensures flight-asset has been configured
"$FLIGHT" asset list 2>/dev/null >&2
valid="$?"
if [ "$valid" -ne 0 ]; then
  cat <<ERROR
Failed to run 'flight asset'
Please ensure it has been configured for the root user and try again:
sudo $flight_ROOT/bin/flight asset configure
ERROR
fi
if [ "$valid" -ne 0 ] && [ "$DRY_RUN" ]; then
  echo 'Continuing dry run...' >&2
elif [ "$valid" -ne 0 ]; then
  exit 1
fi

# Moves to a local temporary directory
exit_code=0
local_dir=$(mktemp -d -t 'asset-info-XXXXXXXX')
pushd $local_dir >/dev/null 2>&1

# Render the assets
for asset in "$@"; do
  info=$("$FLIGHT" inventory show --format flightcenter "$asset"  2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$info" > ./"$asset"
  else
    echo Failed to render: "$asset"
    exit_code=1
  fi
done


# For "Dry Runs" output the directory where the render files are stored
if [ "$DRY_RUN" ]; then
  cat <<INFO
The rendered asset sheets can be found in:
$(pwd)
INFO

# Uploads the asset info
else
  created=()
  for path in *; do
    asset=$(basename $path)

    # Attempts an update
    "$FLIGHT" asset update "$asset" --info @$path 2>/dev/null >&2
    case $? in
    0)
      echo "Exported: $asset"
      ;;
    21)
      # Attempts a create
      "$FLIGHT" asset create "$asset" '' --info @$path 2>/dev/null >&2
      if [ $? -eq 0 ]; then
        echo "Exported: $asset"
        created+=("$asset")
      else
        echo "Failed to export: $asset"
        exit_code=1
      fi
      ;;
    *)
      echo "Failed to export: $asset"
      exit_code=1
      ;;
    esac
  done

  # Remove the temporary directory
  popd >/dev/null 2>&1
  rm -rf $local_dir

  # Gets the info about all the missing nodes
  # NOTE: All created nodes are explicitly made without a group, so appear here
  #       The following code will break if the above assumption does not hold
  #
  # NOTE: When exporting existing nodes with a group, the following output
  #       may print to STDERR. This is to be expected and can be ignored
  list_output=$("$FLIGHT" asset list-assets --group '' 2>/dev/null)

  # Notifies the user about created assets
  if [ "${#created[@]}" -ne 0 ]; then
    echo >&2
    echo The following nodes have been created: >&2
    echo $'Asset\tSupport Type' >&2
    for asset in "${created[@]}"; do
      echo "$list_output" | grep "^$asset"$'\t' | cut -f1,2 >&2
    done
    cat <<UPDATE_COMMAND

You may update the support type with:
$FLIGHT asset update-asset ASSET --support-type TYPE
UPDATE_COMMAND
  fi

  # Determines assets with missing groups
  sorted_assets=$(echo "$@" | xargs -n 1 | sort)
  sorted_missing=$(echo "$list_output" | cut -f1 | xargs -n1 | sort)
  missing=$(comm -12 <(echo $sorted_assets | xargs -n1) <(echo $sorted_missing | xargs -n1))

  if [ -n "$missing" ]; then
    cat <<MOVE_COMMAND >&2

The following assets have not been assigned to a group:
$(echo $missing | xargs)

You may add them to a group with:
$FLIGHT asset update-asset ASSET --group GROUP
MOVE_COMMAND
  fi
fi

exit $exit_code

