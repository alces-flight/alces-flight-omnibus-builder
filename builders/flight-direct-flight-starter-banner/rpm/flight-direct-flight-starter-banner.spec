Name:           flight-direct-flight-starter-banner
Version:        %{_flight_pkg_version}
Release:        %{_flight_pkg_rel}
Summary:        Flight Direct branded banner for Flight Starter

Group:          OpenFlight/Environment
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        %{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      flight-starter >= %{_flight_pkg_now}.0, flight-starter < %{_flight_pkg_next}.0~
Provides:      flight-starter-banner
Conflicts:     flight-starter-banner

%description
Flight Direct branded banner for Flight Starter

%prep

%setup -q -c

%build


%install
cp -R dist/* $RPM_BUILD_ROOT

%clean
#rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) /opt/flight/etc/*.rc
%config(noreplace) /opt/flight/etc/*.cshrc
/opt/flight/etc/banner/banner.erb
/opt/flight/etc/banner/flight.txt
/opt/flight/etc/banner/flight.yml
/opt/flight/libexec/flight-starter/banner
/opt/flight/etc/assets/backgrounds/alces-flight.jpg

%changelog
* Thu May 14 2020 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 2020.2.2
- Updated to 2020.2.2 to match latest OpenFlightHPC release
- Added background image asset
* Wed Dec 11 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 2020.1.0
- Updated numbering scheme
- Updated to 2020.1.0
* Fri Oct  4 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 1.1.0
- Initial Package