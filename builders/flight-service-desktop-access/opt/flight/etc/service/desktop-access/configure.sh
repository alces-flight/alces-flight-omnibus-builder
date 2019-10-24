#!/bin/bash
echo "Configuring"
mkdir -p "${flight_SERVICE_etc}"
>"${flight_SERVICE_etc}/desktop-access.rc"
for a in "$@"; do
  IFS="=" read k v <<< "${a}"
  echo "desktop_access_$k=\"$v\"" >> "${flight_SERVICE_etc}/desktop-access.rc"
  case $k in
    port)
      sed -i "${flight_ROOT}"/etc/www/server-http.d/desktop-access.conf \
          -e "s/^\s*proxy_pass\s.*;/  proxy_pass http://127.0.0.1:${v};/g"
    ;;
    *)
      echo "Unrecognised key: $k"
    ;;
  esac
done
