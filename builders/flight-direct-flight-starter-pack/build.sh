#!/bin/bash
cd "$(dirname "$0")"
mkdir -p $HOME/rpmbuild/SOURCES
cp flight-direct-flight-starter-pack-*.tar.gz $HOME/rpmbuild/SOURCES
rpmbuild -bb flight-direct-flight-starter-pack.spec
mkdir -p pkg
mv $HOME/rpmbuild/RPMS/noarch/flight-direct-flight-starter-pack-*.noarch.rpm pkg
