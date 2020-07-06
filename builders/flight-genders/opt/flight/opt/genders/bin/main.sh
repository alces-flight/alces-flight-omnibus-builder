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
    sudo rm "${GENDERS_FILE}"
    if [[ -f "${GENDERS_FILE_COMPRESSED}" ]] ; then
        sudo rm "${GENDERS_FILE_COMPRESSED}"
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

sanity_check() {
    set +e
    local exit_code
    "${flight_ROOT}"/bin/flight asset list-categories 1>/dev/null 2>&1
    exit_code=$?
    set -e
    if [ $exit_code -eq 5 ] ; then
        echo "flight asset has not been configured"
        exit 2
    fi
    if [ $exit_code -ne 0 ] ; then
        echo "Unexpected error when running 'flight asset' "
        exit 2
    fi
}

usage() {
    local progname
    progname="${FLIGHT_PROGRAM_NAME:-flight-genders}"
    cat <<-EOF

USAGE:

  ${progname} render [FILE]

DESCRIPTION:

  Generate a genders file from Flight Center asset group data.

  If FILE is given the results are written to FILE, otherwise to standard
  output.
EOF
}

render() {
    if [ "$#" -gt 1 ]; then
        echo "Incorrect number of arguments" >&2
        usage
        exit 1
    fi

    sanity_check
    save_genders_file
    compress_genders_file
    if [ "$#" -eq 1 ]; then
        cat ${GENDERS_FILE} > "${1}"
    else
        cat ${GENDERS_FILE}
    fi
}

main() {
    case "$1" in
        --help | -h | help)
            usage
            exit 0
            ;;

        --* | -*)
            echo "Unknown option: ${1}" >&2
            usage
            exit 1
            ;;

        render)
            shift
            render "${@}"
            ;;

        *)
            usage
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
