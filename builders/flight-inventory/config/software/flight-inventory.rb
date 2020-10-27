# NOTE: The following copyright header applies to this software config
COPYRIGHT_HEADER = <<~HEADER.chomp
#==============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of OpenFlight Omnibus Builder.
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
# For more information on OpenFlight Omnibus Builder, please visit:
# https://github.com/openflighthpc/openflight-omnibus-builder
#===============================================================================
HEADER

name 'flight-inventory'
default_version '0.0.0'

source git: 'https://github.com/openflighthpc/flight-inventory'

dependency 'flight-runway'
whitelist_file Regexp.new("vendor/ruby/.*\.so$")

license 'EPL-2.0'
license_file 'LICENSE.txt'
skip_transitive_dependency_licensing true

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Moves the project into place
  [
    'Gemfile', 'Gemfile.lock', 'bin', 'etc', 'lib', 'libexec', 'helpers',
    'LICENSE.txt', 'README.md', 'templates', 'plugins', 'scripts'
  ].each do |file|
    copy file, File.expand_path("#{install_dir}/#{file}/..")
  end

  # Installs the gems to the shared `vendor/share`
  flags = [
    "--without development test",
    '--path vendor'
  ].join(' ')
  command "cd #{install_dir} && /opt/flight/bin/bundle install #{flags}", env: env

  # Write the flight config
  block do
    File.write File.join(install_dir, 'etc/10-flight.conf'), <<~CONF
#{COPYRIGHT_HEADER}

#===============================================================================
# Define the application as part of the flight ecosystem
#===============================================================================
@program_name     = ENV.fetch('FLIGHT_PROGRAM_NAME', 'flight inventory')
@program_version  = '#{version}'

#===============================================================================
# Store the data with the user's XDG cache home
#===============================================================================
@yaml_dir = XDG::Environment.new.cache_home.join("flight/inventory")
CONF
  end
end
