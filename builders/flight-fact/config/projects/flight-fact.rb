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
name 'flight-fact'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/alces-flight/flight-fact'
friendly_name 'Flight Fact'

install_dir '/opt/flight/opt/fact'

VERSION = '1.0.0'
override 'flight-fact', version: VERSION

build_version VERSION
build_iteration 3

dependency 'preparation'
dependency 'flight-fact'
dependency 'version-manifest'

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Manage Alces Flight Center asset metadata entries'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

runtime_dependency 'flight-runway'
runtime_dependency 'flight-ruby-system-2.0'

if ohai['platform_family'] == 'rhel'
  runtime_dependency 'flight-asset >= 1.1.0'
  runtime_dependency 'flight-asset < 2.2.0'
elsif ohai['platform_family'] == 'debian'
  runtime_dependency "flight-asset (>= 1.1.0)"
  runtime_dependency "flight-asset (< 2.2.0)"
else
  raise "Unrecognised platform: #{ohai['platform_family']}"
end

# Updates the version in the libexec file
cmd_path = File.expand_path('../../opt/flight/libexec/commands/fact', __dir__)
cmd = File.read(cmd_path)
          .sub(/^: VERSION: [[:graph:]]+$/, ": VERSION: #{VERSION}")
File.write cmd_path, cmd

# Includes the static files
require 'find'
Find.find('opt') do |o|
  extra_package_file(o) if File.file?(o)
end

config_file '/opt/flight/etc/share/fact.yaml'

package :rpm do
  vendor 'Alces Flight Ltd'
end

package :deb do
  vendor 'Alces Flight Ltd'
end
