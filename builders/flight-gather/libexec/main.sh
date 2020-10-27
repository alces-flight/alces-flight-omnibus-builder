#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
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
#===============================================================================

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VERSION='1.1.0-rc1'

usage() {
    local prog
    prog="flight gather"

    "${flight_ROOT}"/bin/flexec ruby "${flight_ROOT}"/opt/runway/bin/banner title='flight gather' version="$VERSION"

    echo "Usage: ${prog} import ASSET_NAME..."
    echo "  or:  ${prog} export ASSET_NAME..."
    echo "Import inventory data from the cluster and export to Alces Flight Center"
}

main() {
    case "$1" in
        import)
            shift
            bash "$DIR/import.sh" "$@"
            ;;

        export)
            shift
            bash "$DIR/export.sh" "$@"
            ;;

        --help | help)
            usage
            exit 0
            ;;

        *)
            usage
            exit 127
            ;;
    esac
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

