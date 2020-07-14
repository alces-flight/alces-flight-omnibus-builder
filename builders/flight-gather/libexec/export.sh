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

# Ensures flight-asset has been configured
flight asset list 2>/dev/null >&2
if [ $? -ne 0 ]; then
  cat <<ERROR
Failed to run 'flight asset'
Please ensure it has been configured for the root user and try again:
sudo $flight_ROOT/bin/flexec flight asset configure
ERROR
  exit 1
fi

# Moves to a local temporary directory
exit_code=0
local_dir=$(mktemp -d -t 'asset-info-XXXXXXXX')
pushd $local_dir >/dev/null 2>&1

# Render the assets
for asset in "$@"; do
  info=$(flight inventory show $asset 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo $info > ./$asset
  else
    echo "Failed to render: $asset"
    exit_code=1
  fi
done

# Uploads the info
for path in *; do
  asset=$(basename $path)

  # Attempts an update
  flight asset update $asset --info @$path 2>/dev/null >&2
  case $? in
  0)
    echo "Exported (update): $asset"
    ;;
  21)
    # Attempts a create
    flight asset create $asset --info @$path 2>/dev/null >&2
    if [ $? -eq 0 ]; then
      echo "Exported (create): $asset"
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

# Determines assets with missing groups
sorted_assets=$(echo "$@" | xargs -n 1 | sort)
sorted_missing=$(flight asset list-assets --group '' | cut -f1 | xargs -n1 | sort)
missing=$(comm -12 <(echo $sorted_assets | xargs -n1) <(echo $sorted_missing | xargs -n1))

if [ -n "$missing" ]; then
  cat <<HERE >&2

The following assets have not been assigned to a group:
$(echo $missing | xargs)

You may add them to a group with:
flight asset move ASSET GROUP
HERE
fi

exit $exit_code

