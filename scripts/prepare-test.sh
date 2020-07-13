#!/bin/bash
if [ "$UID" != "0" ]; then
  echo "$0: must execute as root"
  exit 1
fi
yum install -y epel-release
DIST=7
yum install -y https://repo.openflighthpc.org/pub/centos/$DIST/openflighthpc-release-latest.noarch.rpm
yum install -y https://alces-flight.s3-eu-west-1.amazonaws.com/repos/pub/centos/$DIST/alces-flight-release-latest.noarch.rpm

yum makecache
