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
#===============================================================================
name 'flight-pdsh-sync'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/openflighthpc/openflight-omnibus-builder/blob/master/builders/flight-pdsh-sync/README.md'
friendly_name 'Flight pdsh sync'

install_dir '/opt/flight/opt/pdsh-sync'

VERSION = '0.1.0'
override 'flight-pdsh-sync', version: VERSION

build_version VERSION
build_iteration 1

dependency 'preparation'
dependency 'flight-pdsh-sync'
dependency 'version-manifest'

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Synchronise pdsh/genders data from Flight Center across a cluster'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

extra_package_file "opt/flight/libexec/commands/pdsh-sync"
extra_package_file "opt/flight/opt/pdsh-sync/bin/sync.sh"

if ohai['platform_family'] == 'rhel'
  runtime_dependency "flight-asset >= 0.5.0"
elsif ohai['platform_family'] == 'debian'
  runtime_dependency "flight-asset (>= 0.5.0)"
end

package :rpm do
  vendor 'Alces Flight Ltd'
  # repurposed 'priority' field to set RPM recommends/provides
  # provides are prefixed with `:`
  # priority ""
end

package :deb do
  vendor 'Alces Flight Ltd'
  # repurposed 'section' field to set DEB recommends/provides
  # entire section is prefixed with `:` to trigger handling
  # provides are further prefixed with `:`
  # section ""
end
