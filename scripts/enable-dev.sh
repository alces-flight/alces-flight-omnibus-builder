#!/bin/bash
if [ "$UID" != "0" ]; then
  echo "$0: must execute as root"
  exit 1
fi
yum-config-manager --disable alces-flight
yum-config-manager --enable alces-flight-dev
yum-config-manager --disable openflight
yum-config-manager --enable openflight-dev
