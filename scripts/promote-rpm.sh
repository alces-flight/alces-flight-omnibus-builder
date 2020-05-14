#!/bin/bash
#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
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
# Promotes one or more RPMs between repos.
set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -z "$2" ]; then
  echo "Usage: $0 <rpm pattern> <distribution>"
  exit 1
fi

if ! aws --profile alces-flight s3 ls &>/dev/null; then
  echo "$0: unable to access S3; check credentials? -- try 'aws configure --profile alces-flight'"
  exit 1
fi


# Check Slack notifications configured
$SCRIPT_DIR/slack-check.sh

export RPM_PATTERN="$1"
DIST="$2"
$SCRIPT_DIR/promote-rpms.sh -s "alces-flight/repos/alces-flight-dev" \
                            -t "alces-flight/repos/alces-flight" \
                            -r "$RPM_PATTERN" \
                            -d "$DIST"
