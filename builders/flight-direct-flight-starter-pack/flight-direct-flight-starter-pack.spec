Name:           flight-direct-flight-starter-pack
Version:        1.0.0
Release:        1
Summary:        Flight Starter pack for use with Flight Direct HPC environments

Group:          Flight/Environment
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        %{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      flight-starter

%description
Flight Starter pack for use with Flight Direct HPC environments

%prep
%setup -q -c

%build

%install
cp -R dist/* $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/opt/flight/etc/profile.d/*.sh
/opt/flight/etc/profile.d/*.csh
/opt/flight/libexec/flight-starter/quota-check

%changelog
* Mon Oct 14 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 1.0.0
- Initial Package
