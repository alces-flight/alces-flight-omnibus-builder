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

# Moves to a local temporary directory
exit_code=0
local_dir=$(mktemp -d -t 'asset-info-XXXXXXXX')
pushd $local_dir >/dev/null 2>&1

# Render the assets
for asset in "$@"; do
  flight inventory show $asset > ./$asset
  if [ $? -ne 0 ]; then
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

exit $exit_code

