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
name 'flight-fact'
default_version '0.0.0'

source git: 'https://github.com/alces-flight/flight-fact'

dependency 'enforce-flight-runway'
whitelist_file Regexp.new("vendor/ruby/.*\.so$")

license 'EPL-2.0'
license_file 'LICENSE.txt'
skip_transitive_dependency_licensing true

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Moves the project into place
  # We don't copy bin/ as we write our own production bin/asset in the project.
  [
    'Gemfile', 'Gemfile.lock', 'bin', 'etc', 'lib', 'LICENSE.txt', 'README.md'
  ].each do |file|
    copy file, File.expand_path("#{install_dir}/#{file}/..")
  end

  # Installs the gems to the shared `vendor/share`
  flags = [
    "--without development test",
    '--path vendor'
  ].join(' ')
  command "cd #{install_dir} && /opt/flight/bin/bundle install #{flags}", env: env

  # Links the config into the system location
  block do
    FileUtils.ln_sf '/opt/flight/etc/share/fact.yaml', File.expand_path('etc/config.yaml', install_dir)
  end
end
