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
# Promotes an RPM from one repo to another (e.g. dev -> prod)
set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

DEPENDENCIES=("aws" "createrepo")
REGION="eu-west-1"

while getopts "s:t:r:" opt; do
  case $opt in
    r) RPM_MATCH=$OPTARG ;;
    s) SOURCE_PREFIX=$OPTARG ;;
    t) TARGET_PREFIX=$OPTARG ;;
    d) DIST=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

for dep in "${DEPENDENCIES[@]}"
do
  if [ ! $(which ${dep}) ]; then
      echo "${dep} must be available."
      exit 1
  fi
done

if [ -z "${RPM_MATCH}" ]; then
  echo "RPM match string must be specified."
  exit 1
fi

if [ -z "${SOURCE_PREFIX}" ]; then
  echo "Source bucket prefix must be specified."
  exit 1
fi

if [ -z "${TARGET_PREFIX}" ]; then
  echo "Target bucket prefix must be specified."
  exit 1
fi

# distribution targets
DIST_TARGETS="7 8"

if [[ "$DIST_TARGETS" != *"$DIST"* ]] ; then
    echo "Unknown distribution: $DIST"
    echo "Distribution should be one of: $DIST_TARGETS"
    exit 1
fi

# work-around for legacy locations
if [ "$DIST" == "7" ]; then
  SOURCE_PREFIX="${SOURCE_PREFIX}"
  TARGET_PREFIX="${TARGET_PREFIX}"
else
  SOURCE_PREFIX="${SOURCE_PREFIX}/$DIST"
  TARGET_PREFIX="${TARGET_PREFIX}/$DIST"
fi

SOURCE_DIR="/tmp/${SOURCE_PREFIX}"
TARGET_DIR="/tmp/${TARGET_PREFIX}"

# make sure we're operating on the latest data in the source bucket
mkdir -p $SOURCE_DIR
aws --profile alces-flight --region "${REGION}" s3 sync --delete "s3://${SOURCE_PREFIX}" $SOURCE_DIR

# make sure we're operating on the latest data in the target bucket
mkdir -p $TARGET_DIR
aws --profile alces-flight --region "${REGION}" s3 sync --delete "s3://${TARGET_PREFIX}" $TARGET_DIR

# copy the RPM in and update the repo
NOARCH_TARGETS="x86_64 aarch64"
bash -c "mkdir -pv $TARGET_DIR/{${NOARCH_TARGETS/ /,}}/"
shopt -s nullglob

# Locate RPM
matches="$(find $SOURCE_DIR -path "*$RPM_MATCH*")"
shopt -u nullglob


# Exit if no matches found
if [ -z "$matches" ]; then
  echo "No match found: $SOURCE_DIR/{${NOARCH_TARGETS/ /,}}/${RPM_MATCH}*"
  exit 1
fi

# Exit if more than one match found
if [[ $(echo "$matches" |wc -l) -gt 1 ]] ; then
    echo "More than one match found: "
    echo "$matches"
    echo
    echo "Please refine the argument to match more specifically, this can be done by ensuring that version number, build date, architecture and parent directory are included in the argument:"
    echo "    aarch64/flight-starter-banner-1.2.1-1.noarch.rpm"
    exit 1
fi

echo "Match: $matches"

ARCH="$(rpm -qip $matches |grep '^Architecture' |awk '{print $2}')"

# Push to all architectures if noarch rpm
if [ "$ARCH" == "noarch" ] ; then
    for arch in $NOARCH_TARGETS ; do 
        cp -rv ${matches} $TARGET_DIR/$arch/
        UPDATE=""
        if [ -e "${TARGET_DIR}/$arch/repodata/repomd.xml" ]; then
          UPDATE="--update "
        fi
        createrepo -v $UPDATE --deltas $TARGET_DIR/$arch/
    done
else
    cp -rv ${matches} $TARGET_DIR/$ARCH/
    UPDATE=""
    if [ -e "${TARGET_DIR}/$ARCH/repodata/repomd.xml" ]; then
      UPDATE="--update "
    fi
    createrepo -v $UPDATE --deltas $TARGET_DIR/$ARCH/
fi

# sync the repo state back to s3
aws --profile alces-flight --region "${REGION}" s3 sync --delete $TARGET_DIR s3://$TARGET_PREFIX --acl public-read

# Notify slack
if [ "$ARCH" == "noarch" ] ; then ARCH="x86_64" ; fi
export PACKAGE=$(echo "$matches" |sed 's/.*\///g')
export REPO=$(echo "$TARGET_PREFIX" |sed 's/.*org\///g')
export PACKAGE_URL=https://$TARGET_PREFIX/$ARCH/$PACKAGE
$SCRIPT_DIR/slack-update.sh
