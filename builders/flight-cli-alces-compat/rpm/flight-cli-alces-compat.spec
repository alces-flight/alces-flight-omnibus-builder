Name:           flight-cli-alces-compat
Version:        %{_flight_pkg_version}
Release:        %{_flight_pkg_rel}
Summary:        Compatibility shim for the legacy "alces" command

Group:          OpenFlight/Environment
License:        CC-BY-SA

URL:            https://alces-flight.com
Source0:        flight-cli-alces-compat-07-alces.sh
Source1:        flight-cli-alces-compat-LICENSE.txt

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      flight-runway

%description
Compatibility shim for the legacy "alces" command

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/flight/etc/profile.d
install -p -m 644 %{SOURCE0} $RPM_BUILD_ROOT/opt/flight/etc/profile.d/07-alces.sh
install -p -m 644 %{SOURCE1} LICENSE.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%license LICENSE.txt
/opt/flight/etc/profile.d/07-alces.sh

%changelog
* Tue May 19 2020 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 1.0.0
- Initial Package
