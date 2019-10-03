#!/bin/bash
cd "$(dirname "$0")"
rpmbuild -bb alces-flight-release.spec
mkdir -p pkg
mv $HOME/rpmbuild/RPMS/noarch/alces-flight-release-*.noarch.rpm pkg
