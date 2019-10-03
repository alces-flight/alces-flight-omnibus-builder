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

SOURCE_DIR="/tmp/${SOURCE_PREFIX}"
TARGET_DIR="/tmp/${TARGET_PREFIX}"

# make sure we're operating on the latest data in the source bucket
mkdir -p $SOURCE_DIR
aws --region "${REGION}" s3 sync "s3://${SOURCE_PREFIX}" $SOURCE_DIR

# make sure we're operating on the latest data in the target bucket
mkdir -p $TARGET_DIR
aws --region "${REGION}" s3 sync "s3://${TARGET_PREFIX}" $TARGET_DIR

# copy the RPM in and update the repo
mkdir -pv $TARGET_DIR/x86_64/
shopt -s nullglob
targets="$(echo $SOURCE_DIR/x86_64/${RPM_MATCH}.{noarch,x86_64}.rpm*)"
echo targets: $targets
shopt -u nullglob
if [ -z "$targets" ]; then
  echo "No match found: $SOURCE_DIR/x86_64/${RPM_MATCH}.{noarch,x86_64}.rpm"
  exit 1
fi
cp -rv ${targets} $TARGET_DIR/x86_64/
UPDATE=""
if [ -e "${TARGET_DIR}/noarch/repodata/repomd.xml" ]; then
  UPDATE="--update "
fi
createrepo -v $UPDATE --deltas $TARGET_DIR/x86_64/

# sync the repo state back to s3
aws --region "${REGION}" s3 sync $TARGET_DIR s3://$TARGET_PREFIX
