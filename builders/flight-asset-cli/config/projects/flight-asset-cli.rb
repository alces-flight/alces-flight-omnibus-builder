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
name 'flight-asset-cli'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/alces-flight/flight-asset-cli'
friendly_name 'Flight Asset CLI'

install_dir '/opt/flight/opt/asset-cli'

VERSION = '0.2.0'

build_version VERSION
build_iteration 1

override 'flight-asset-cli', version: VERSION

dependency 'preparation'
dependency 'flight-asset-cli'
dependency 'version-manifest'

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Manage interactive GUI desktop sessions'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

runtime_dependency 'flight-runway >= 1.1.0, flight-runway < 1.2.0'

# Updates the version in the libexec file
cmd_path = File.expand_path('../../opt/flight/libexec/commands/asset', __dir__)
cmd = File.read(cmd_path)
          .sub(/^: VERSION: [[:graph:]]+$/, ": VERSION: #{VERSION}")
File.write cmd_path, cmd

# Includes the static files
require 'find'
Find.find('opt') do |o|
  extra_package_file(o) if File.file?(o)
end

package :rpm do
  vendor 'Alces Flight Ltd'
end
