#!/bin/bash
echo "Starting"
if [ -f ${flight_SERVICE_etc}/desktop-access.rc ]; then
  . ${flight_SERVICE_etc}/desktop-access.rc
fi
mkdir -p "${flight_ROOT}"/var/run
mkdir -p "${flight_ROOT}"/var/log/desktop-access
desktop_access_port="${desktop_access_port:-41180}"
cd ${flight_ROOT}/opt/desktop-access
tool_bg ${flight_ROOT}/bin/ruby bin/rackup \
        -p ${desktop_access_port} \
        -D \
        -P "${flight_ROOT}/var/run/desktop-access.pid"
wait
c=0
while [ ! -f "${flight_ROOT}/var/run/desktop-access.pid" ]; do
  c=$(($c+1))
  if [ $c -lt 5 ]; then
    sleep 2
  fi
done
tool_set pid=$(cat "${flight_ROOT}/var/run/desktop-access.pid")
