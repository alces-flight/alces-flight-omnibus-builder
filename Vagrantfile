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
Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.6"
  code_path = ENV['FLIGHT_CODE'] || "#{ENV['HOME']}/code"

  config.vm.define "default", primary: true do |build|
    build.vm.provision "shell", path: "vagrant/provision.sh"
    if File.directory?(code_path)
      build.vm.synced_folder code_path, "/code"
    end
  end
  config.vm.define "test", autostart: false do |build|
    if File.directory?(code_path)
      build.vm.synced_folder code_path, "/code"
    end
  end
end
