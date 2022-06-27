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
name 'alces-flight-landing-page-branding'
maintainer 'Alces Flight Ltd'
homepage 'https://github.com/alces-flight/alces-flight-omnibus-builders/builders/alces-flight-landing-page-branding'
friendly_name 'Alces Flight landing page branding'

install_dir '/opt/flight/opt/www/landing-page/branding'

VERSION = '1.7.0'
override 'alces-flight-landing-page-branding', version: VERSION

build_version VERSION
build_iteration '1'

dependency 'preparation'
dependency 'alces-flight-landing-page-branding'
dependency 'version-manifest'

if ohai['platform_family'] == 'rhel'
  conflict 'flight-www < 1.3.1~'
elsif ohai['platform_family'] == 'debian'
  conflict 'flight-www (< 1.3.1~)'
else
  raise "Unrecognised platform: #{ohai['platform_family']}"
end

license 'EPL-2.0'
license_file 'LICENSE.txt'

description 'Alces Flight branding for use with flight-www'

exclude '**/.git'
exclude '**/.gitkeep'
exclude '**/bundler/git'

package :rpm do
  vendor 'Alces Flight Ltd'
  # repurposed 'priority' field to set RPM recommends/provides
  # provides are prefixed with `:`
  priority ":flight-landing-page-branding"
end

package :deb do
  vendor 'Alces Flight Ltd'
  # repurposed 'section' field to set DEB recommends/provides
  # entire section is prefixed with `:` to trigger handling
  # provides are further prefixed with `:`
  section "::flight-landing-page-branding"
end
