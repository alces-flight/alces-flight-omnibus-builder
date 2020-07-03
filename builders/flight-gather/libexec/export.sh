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

flight='/opt/flight/bin/flight'
exit_code=0

update_asset() {
  $flight asset update $1 --info <<INFO
$info
INFO
  echo $?
}

create_asset() {
  $flight asset create $1 --info <<INFO
$info
INFO
  echo $?
}

for asset in "$@"; do
  # Renders the info field
  info=$($flight inventory show $asset)

  if [ $? -eq 0 ]; then
    update_code=$(update_asset $asset)
    case $update_code in
    0)
      echo "Exported: $asset"
      ;;
    21)
      create_code=$(create_asset $asset)
      if [ $create_code -eq 0]; then
        echo "Exported: $asset"
      else
        echo "Failed to create: $asset" >&2
        exit_code=1
      fi
      ;;
    *)
      echo "Failed to update: $asset" >&2
      exit_code=1
      ;;
    esac
  else
    echo "Failed to render: $asset" >&2
    exit_code=1
  fi
done

exit $exit_code

