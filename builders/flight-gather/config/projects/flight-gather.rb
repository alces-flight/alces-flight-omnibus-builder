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
name 'flight-gather'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/alces-flight/alces-flight-omnibus-builder'
friendly_name 'Flight Gather'

install_dir '/opt/flight/opt/gather'

VERSION = '0.1.6'

build_version VERSION
build_iteration 1

dependency 'preparation'
dependency 'flight-gather'
dependency 'version-manifest'

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Orchestrate the gathering and exporting inventory data'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

if ohai['platform_family'] == 'rhel'
  runtime_dependency 'flight-asset >= 1.0.0, flight-asset < 2.0.0'
  # HACK: README BEFORE RELEASING 1.0.0
  # The dependency on `flight-inventory 2.0.0~` allow rcX releases of inventory
  # The ~ should be removed before a production release is made
  runtime_dependency 'flight-inventory >= 2.0.0~, flight-inventory < 2.1.0'
  runtime_dependency 'flight-runway >= 1.1.4'
elsif ohai['platform_family'] == 'debian'
  runtime_dependency 'flight-asset (>= 1.0.0), flight-asset (< 2.0.0)'
  runtime_dependency 'flight-inventory (>= 2.0.0), flight-inventory (< 2.1.0)'
  runtime_dependency "flight-runway (>= 1.1.4)"
else
  raise "Unrecognised platform: #{ohai['platform_family']}"
end

# Updates the version in the libexec file
cmd_path = File.expand_path('../../opt/flight/libexec/commands/gather', __dir__)
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
