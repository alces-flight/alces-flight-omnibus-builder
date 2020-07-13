#!/bin/bash
PLUGIN=pam
# The RPM package version
VERSION=0.1.1
REL=1
# The tag in the repo to build.
TAG=${VERSION}

cd "$(dirname "$0")"
d="$(pwd)"
mkdir -p pkg

build() {
  TYPE=$1
  NAME=flight-plugin-${TYPE}-${PLUGIN}
  if [ -f /etc/redhat-release ]; then
    echo "Building RPM package..."
    sudo yum install -y pam-devel libcurl-devel
    cd rpm
    rpmbuild -bb ${NAME}.spec \
             --define "_flight_pkg_version $VERSION" \
             --define "_flight_pkg_rel $REL" \
             --define "_flight_repo_name flight-pam" \
             --define "_flight_repo_tag $TAG"
    cd ..
    mv $HOME/rpmbuild/RPMS/*/${NAME}-${VERSION}*.rpm pkg
  
  elif [ -f /etc/lsb-release ]; then
    echo "Building DEB package..."

    mkdir -p $HOME/${NAME}

    pushd $HOME/${NAME}
    rm -rf ${NAME}-${VERSION}
    mkdir -p ${NAME}-${VERSION}
    mkdir -p ${NAME}_${VERSION}-$REL/DEBIAN
    sed -e "s/%VERSION%/$VERSION/g" \
        -e "s/%REL%/$REL/g" \
        $d/deb/$NAME.control.tpl > \
        $HOME/${NAME}/${NAME}_${VERSION}-$REL/DEBIAN/control

    pushd ${NAME}_${VERSION}-$REL

    wget https://raw.githubusercontent.com/alces-flight/alces-flight-omnibus-builder/flight-pam/builders/flight-pam/dist/etc/pam.d/flight

    case $TYPE in
      system)
        echo "system plugin not supported"
        exit 2
        ;;

      manual)
        mkdir -p opt/flight/etc/pam.d
        mv flight opt/flight/etc/pam.d/
        chmod 644 opt/flight/etc/pam.d/flight

        ;;
      *)
        echo "Couldn't determine plugin type to build."
        ;;
    esac
    mkdir -p usr/share/doc/${NAME}
    mv LICENSE.txt usr/share/doc/${NAME}
    popd

    fakeroot dpkg-deb --build ${NAME}_${VERSION}-$REL
    popd

    mv $HOME/${NAME}/*.deb pkg
  else
    echo "Couldn't determine type of package to build."
    exit 1
  fi
}

build manual
