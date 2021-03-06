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
    prog="flight gather import"
    cat <<USAGE
Usage: ${prog} [--help] [--verbose] ASSET_NAME...
Profile the assets and import the data into 'flight inventory'
  --help    Display this help text
  --verbose Display the full profiler output
USAGE
}

# Parse the help and verbose flags
PARAMS=""
VERBOSE=
while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      exit
      ;;
    --verbose)
        VERBOSE=true
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Moves to a local temporary directory
local_dir=$(mktemp -d -t 'gather-XXXXXXXX')
pushd $local_dir >/dev/null 2>&1

# Profile all the assets
for asset in "$@"; do
  if [ -z "${VERBOSE}" ]; then
    echo -n "Gathering: ${asset}..."
    bash $DIR/profile.sh $asset > ${asset}.log
    STATUS=$?
  else
    echo "Gathering: ${asset}..."
    bash $DIR/profile.sh $asset
    STATUS=$?
  fi
  if [ ${STATUS} -eq 0 ]; then
    echo "OK"
  else
    echo "Failed"
  fi
done

if test -n "$(find "${local_dir}" -maxdepth 1 -name '*.zip' -print -quit)"; then
  # Import the assets into flight-inventory
  ls $local_dir/*.zip | xargs -n 1 /opt/flight/bin/flight inventory import
else
  echo
  echo "No files to import found."
fi

# Remove the temporary directory
popd >/dev/null 2>&1
rm -rf $local_dir
