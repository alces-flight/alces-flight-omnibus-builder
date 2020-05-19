#!/bin/bash
cd "$(dirname "$0")"
d="$(pwd)"
mkdir -p pkg

NAME=flight-cli-alces-compat
VERSION=1.0.0
REL=1

if [ -f /etc/redhat-release ]; then
  echo "Building RPM package..."
  rm -rf $HOME/rpmbuild/SOURCES/flight-cli-alces-compat-*
  cp $d/../../LICENSE.txt $HOME/rpmbuild/SOURCES/flight-cli-alces-compat-LICENSE.txt
  cp dist/07-alces.sh $HOME/rpmbuild/SOURCES/flight-cli-alces-compat-07-alces.sh
  cd rpm
  rpmbuild -bb ${NAME}.spec \
           --define "_flight_pkg_version $VERSION" \
           --define "_flight_pkg_rel $REL"
  cd ..
  mv $HOME/rpmbuild/RPMS/noarch/${NAME}-*.noarch.rpm pkg
elif [ -f /etc/lsb-release ]; then
  echo "Building DEB package..."

  mkdir -p $HOME/${NAME}

  pushd $HOME/${NAME}
  rm -rf ${NAME}-${VERSION}
  rm -rf ${NAME}_${VERSION}-${REL}
  mkdir -p ${NAME}_${VERSION}-$REL/DEBIAN
  sed -e "s/%VERSION%/$VERSION/g" \
      -e "s/%REL%/$REL/g" \
      $d/deb/control.tpl > \
      $HOME/${NAME}/${NAME}_${VERSION}-$REL/DEBIAN/control

  pushd ${NAME}_${VERSION}-$REL
  mkdir -p usr/share/doc/${NAME}
  install -p -m 644 $d/../../LICENSE.txt usr/share/doc/${NAME}
  mkdir -p opt/flight/etc/profile.d
  install -p -m 644 $d/dist/07-alces.sh opt/flight/etc/profile.d
  popd

  dpkg-deb --build ${NAME}_${VERSION}-$REL
  popd

  mv $HOME/${NAME}/*.deb pkg
else
  echo "Couldn't determine type of package to build."
fi
