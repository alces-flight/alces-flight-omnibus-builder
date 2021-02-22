#!/bin/bash
cd "$(dirname "$0")"
d="$(pwd)"
mkdir -p pkg

NAME=flight-direct-flight-starter-banner
NOW=2021.1
NEXT=2021.2
VERSION=${NOW}.0
REL=1

if [ ! -e ${NAME}-${VERSION}.tar.gz ]; then
  echo "Unable to find source tarball: ${NAME}-${VERSION}.tar.gz"
  exit 1
fi

if [ -f /etc/redhat-release ]; then
  echo "Building RPM package..."
  mkdir -p $HOME/rpmbuild/SOURCES
  cp ${NAME}-${VERSION}.tar.gz $HOME/rpmbuild/SOURCES
  cd rpm
  rpmbuild -bb ${NAME}.spec \
           --define "_flight_pkg_version $VERSION" \
           --define "_flight_pkg_rel $REL" \
           --define "_flight_pkg_now $NOW" \
           --define "_flight_pkg_next $NEXT"
  cd ..
  mv $HOME/rpmbuild/RPMS/noarch/${NAME}-*.noarch.rpm pkg
elif [ -f /etc/lsb-release ]; then
  echo "Building DEB package..."

  rm -rf $HOME/${NAME}/${NAME}-${VERSION}
  mkdir -p $HOME/${NAME}/${NAME}-${VERSION}
  tar -C $HOME/${NAME}/${NAME}-${VERSION} -xzf ${NAME}-${VERSION}.tar.gz

  pushd $HOME/${NAME}
  rm -rf ${NAME}_${VERSION}-${REL}
  mkdir -p ${NAME}_${VERSION}-${REL}/DEBIAN
  sed -e "s/%VERSION%/$VERSION/g" \
      -e "s/%REL%/$REL/g" \
      -e "s/%NOW%/$NOW/g" \
      -e "s/%NEXT%/$NEXT/g" \
      $d/deb/control.tpl > \
      $HOME/${NAME}/${NAME}_${VERSION}-${REL}/DEBIAN/control

  mv ${NAME}-${VERSION}/dist/* ${NAME}_${VERSION}-${REL}
  dpkg-deb --build ${NAME}_${VERSION}-${REL}
  popd

  mv $HOME/${NAME}/*.deb pkg
else
  echo "Couldn't determine type of package to build."
fi
