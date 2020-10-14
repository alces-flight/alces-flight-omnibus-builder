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
name 'flight-docs'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/alces-flight/flight-docs'
friendly_name 'Flight Docs'

install_dir '/opt/flight/opt/docs'

VERSION = '1.0.2'
override 'flight-docs', version: VERSION

build_version VERSION
build_iteration 1

dependency 'preparation'
dependency 'flight-docs'
dependency 'version-manifest'

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Access your Alces Flight Center documents'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

runtime_dependency 'flight-runway'
runtime_dependency 'flight-ruby-system-2.0'
runtime_dependency 'flight-account'

# Updates the version in the libexec file
cmd_path = File.expand_path('../../opt/flight/libexec/commands/docs', __dir__)
cmd = File.read(cmd_path)
          .sub(/^: VERSION: [[:graph:]]+$/, ": VERSION: #{VERSION}")
File.write cmd_path, cmd

# Copies the correct howto version into place
howto_src = File.expand_path("../../contrib/howto/#{VERSION.sub(/\.\d+(-\w.*)?\Z/, '')}", __dir__)
howto_dst = File.expand_path("../../opt/flight/usr/share/howto/flight-docs.md", __dir__)
raise "Could not locate: #{howto_src}" unless File.exists? howto_src
FileUtils.mkdir_p File.dirname(howto_dst)
FileUtils.rm_f howto_dst
FileUtils.cp howto_src, howto_dst

# Includes the static files after updating the opt directory
require 'find'
Find.find('opt') do |o|
  extra_package_file(o) if File.file?(o)
end

package :rpm do
  vendor 'Alces Flight Ltd'
  # repurposed 'priority' field to set RPM recommends/provides
  # provides are prefixed with `:`
  priority "flight-howto-system-1.0"
end

package :deb do
  # repurposed 'section' field to set DEB recommends/provides
  # entire section is prefixed with `:` to trigger handling
  # provides are further prefixed with `:`
  vendor 'Alces Flight Ltd'
  section ":flight-howto-system-1.0"
end
