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

# This is a "temporary" fix that avoids the use of `flexec` bash function
# The `flexec` script file is fine
# https://github.com/openflighthpc/openflight-omnibus-builder/issues/33

# Squash ruby deprecation warnings
export RUBYOPT='-W:no-deprecated -W:no-experimental'

# Use the first argument as the app name
app_name=$1
shift

# Save the current directory and move to the app dir
export FLIGHT_CWD=$(pwd)
cd /opt/flight/opt/$app_name

# Set the program name and execute
export FLIGHT_PROGRAM_NAME="${flight_NAME} $app_name"
/opt/flight/bin/flexec bundle exec bin/$app_name "$@"

