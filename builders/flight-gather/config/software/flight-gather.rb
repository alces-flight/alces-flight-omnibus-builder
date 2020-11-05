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
default_version '0'

version('2020.1') { source sha256: 'b28124b85b99ce82d853631d4f7955dbb1dfbc8c0da1c21cc9aa160a4c791c36' }
version('2020.2') { source sha256: 'e2b4a3d88fa893d06abc7a82eb08d7e0838d190e3f81c396f6ddf61368471f07' }

source url: "https://raw.githubusercontent.com/openflighthpc/flight-inventory-data-gatherer/#{version}/build/gather-data-bundled.sh"

license 'EPL-2.0'
license_file 'LICENSE.txt'
skip_transitive_dependency_licensing true

build do
  # Copy the downloaded gather binary into bin
  src = File.join(project_dir, 'gather-data-bundled.sh')
  dst = File.join(install_dir, 'libexec/gatherer.sh')
  block do
    FileUtils.mkdir_p File.dirname(dst)
    FileUtils.cp src, dst
    FileUtils.chmod 0664, dst
  end

  # Copy the associated files into /o/f/o/gather/libexec
  Dir.glob(File.expand_path('../../libexec/*', __dir__)).each do |path|
    copy path, File.join(install_dir, 'libexec')
  end
end
