#!/bin/bash
#==============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of Alces Flight Omnibus Builder.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# This project is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with this project. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Alces Flight Omnibus Builder, please visit:
# https://github.com/alces-flight/alces-flight-omnibus-builder
# ==============================================================================
set -e

GENDERS_FILE=$(mktemp /tmp/flight-asset-genders.XXXXXXXX)
GENDERS_FILE_COMPRESSED=$(mktemp /tmp/flight-asset-genders.compressed.XXXXXXXX)
clean_up() {
    rm "${GENDERS_FILE}"
    if [[ -f "${GENDERS_FILE_COMPRESSED}" ]] ; then
        rm "${GENDERS_FILE_COMPRESSED}"
    fi
}
trap clean_up EXIT

build_genders_file() {
    "${flight_ROOT}"/bin/flight asset list \
        | awk '
            BEGIN { FS="\t"; OFS="\t" }
            {
                if ($1 ~ /\./) { 
                    printf "Ignoring %s: name contains a .\n",$1 >> "/dev/stderr"
                } else {
                    if (length($5) > 0) {
                        printf "%s\t%s,all\n",$1,$5
                    } else {
                        printf "%s\tall\n",$1
                    }
                }
            }
        '
}

save_genders_file() {
    build_genders_file > "${GENDERS_FILE}"
}

compress_genders_file() {
    if type nodeattr >/dev/null 2>&1 ; then
        if nodeattr 2>&1 | grep -q -- --compress-hosts ; then
            nodeattr -f "${GENDERS_FILE}" --compress-hosts > "${GENDERS_FILE_COMPRESSED}"
        else
            nodeattr -f "${GENDERS_FILE}" --compress > "${GENDERS_FILE_COMPRESSED}"
        fi
        mv -f "${GENDERS_FILE_COMPRESSED}" "${GENDERS_FILE}"
    fi
}

install_genders_file() {
    pdcp -g all -F "${GENDERS_FILE}" "${GENDERS_FILE}" "${flight_ROOT}"/etc/genders
}

sanity_check() {
    if type pdcp >/dev/null 2>&1 ; then
        # We have `pdcp` available.
        :
    else
        echo "pdcp command not found." 2>&1
        echo "Ensure pdcp is available on \$PATH and try again." 2>&1
        exit 1
    fi
    set +e
    local exit_code
    "${flight_ROOT}"/bin/flight asset show-asset non-existant-68b329 1>/dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 5 ] ; then
        echo "flight asset has not been configured for the root user"
        exit 2
    fi
    if [ $exit_code -ne 0 ] ; then
        echo "Unexpected error when running 'flight asset' "
        exit 2
    fi
}

main() {
    sanity_check
    echo "Building genders file"
    save_genders_file
    echo "Compressing genders file"
    compress_genders_file
    if type nodeattr >/dev/null 2>&1 ; then
        echo "Copying genders file to $(nodeattr -f "${GENDERS_FILE}" -q all)"
    else
        echo "Copying genders file"
    fi
    install_genders_file
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
