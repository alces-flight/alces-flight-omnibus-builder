# Alces Flight Omnibus Builder

Build infrastructure for creating platform-specific builds of Alces Flight projects with Omnibus.

## Overview

The Alces Flight Omnibus Builder repository provides build instructions and configuration to allow complex Alces Flight projects to be built for distribution for particular platforms (primarily Enterprise Linux) using [Omnibus](https://github.com/chef/omnibus).  This allows them to be shipped along with their necessary dependencies on versions of upstream projects that aren't made available as part of the distribution, for e.g. more advanced Ruby versions, latest VNC servers etc.

## Installation

### Prerequisites

The build infrastructure requires that you have a working [Vagrant](https://www.vagrantup.com/) installation.

### Install the build environment

#### Clone the repo

Firstly, clone the repo!

```
git clone https://github.com/alces-flight/alces-flight-omnibus-builder
```

#### Initialize build VM

Bring up the EL7 build VM:

```
cd alces-flight-omnibus-builder
vagrant up
```

The EL7 build VM will be provisioned with the required tools including required distribution dependencies via `yum` and an RVM installation of Ruby 2.6.

Access the build VM using `vagrant ssh`.  The build infrastructure is mounted within the guest at `/vagrant`.

#### Initialize build infrastructure within the VM

Log in to the build VM and set up the Omnibus build infrastructure.

```
vagrant ssh
cd /vagrant/builders/flight-example
bundle install
```

## Building a project

The build infrastructure is set up so as not to need root access.  This is important because, when building and installing complex projects, the installation of any software dependencies that attempt to write outside of the `/opt/flight` hierarchy will fail fast allowing potential problems to be corrected.

To build a project, enter the project directory within `/vagrant/builders` and issue the `omnibus build` command, e.g.:

```
cd /vagrant/builders/flight-example
bin/omnibus build flight-example
```

Once the build has completed, the RPM package will be available in the `pkg/` subdirectory.


## Testing built packages

The `Vagrantfile` also contains a definition for a simple VM you can use to test built packages.  Manage and access the test VM using the `test` definition:

```
vagrant up test
vagrant ssh test
```

Similarly to the build VM, the build infrastructure is mounted within the guest at `/vagrant` where you can find the packages you built within the build VM, for e.g.:

```
sudo -s
cd /vagrant/builders/flight-example
yum install pkg/flight-example-someversion.el7.x86_64.rpm
```

## Uploading built packages to the `yum` repo

Once a package is built, the result can be uploaded to a `yum` repository.

### Publishing to the development repo

Alces Flight contributors who have been provided with permissions to publish to the Alces Flight `yum` repositories on Amazon S3, can use the `scripts/publish-rpm.sh` script to push an RPM to the development repository.

First, add your AWS credentials:

```
aws configure
```

Next, publish the RPM that you've built:

```
scripts/publish-rpm.sh builders/flight-example/pkg/flight-example-someversion.rpm
```

Users of the `alces-flight-dev` repository will then have access to install the new RPM via `yum` on their systems.

### Promoting to the production repo

Once the RPM has been tested, you can promote it to the live/production repo using the `scripts/promote-rpm.sh` script:

```
scripts/promote-rpm.sh flight-example-someversion
```

Note that the script does not take a file path, but takes a name pattern to match one or more RPMs that are present in the development repo.

Once the RPM is published to the production repo, users of the `alces-flight` repository will have access to install/upgrade to the new RPM via `yum` on their systems.

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Alces Flight Omnibus Builder is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.
