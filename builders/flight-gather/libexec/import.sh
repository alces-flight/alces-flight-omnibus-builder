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

BINARY="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )/gatherer.sh"

# Moves to a local temporary directory
pushd $(mktemp -d -t 'gather-XXXXXXXX')

# Profile all the assets
for asset in "$@"; do
  echo "Import: $asset"

  # Move the binary into place
  bin=$(ssh $asset mktemp -t generate.XXXXXXXX.sh)
  scp $BINARY $asset:$bin

  # Run the binary and copy the zip down
  ssh $asset bash $bin
  scp $asset:/tmp/$asset.zip .

  # Delete the remote binary and zip
  ssh $asset rm -f $bin /tmp/$asset.zip
done

# Import the assets into flight-inventory
/opt/flight/bin/flight inventory .

# Remove the temporary directory
rm -rf $(popd)

