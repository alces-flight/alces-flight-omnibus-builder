#!/bin/bash
cd "$(dirname "$0")"
mkdir -p $HOME/rpmbuild/SOURCES
cp flight-direct-flight-starter-banner-*.tar.gz $HOME/rpmbuild/SOURCES
rpmbuild -bb flight-direct-flight-starter-banner.spec
mkdir -p pkg
mv $HOME/rpmbuild/RPMS/noarch/flight-direct-flight-starter-banner-*.noarch.rpm pkg
