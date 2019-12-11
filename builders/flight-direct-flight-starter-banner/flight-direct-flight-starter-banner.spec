Name:           flight-direct-flight-starter-banner
Version:        2020.1.0
Release:        1
Summary:        Flight Direct branded banner for Flight Starter

Group:          OpenFlight/Environment
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        %{name}-%{version}.tar.gz
%define SHA256SUM0 82e13e0caf6d02d8b8ac12cc51acda3ee0c4609938e12549ec631812d484faa3

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      flight-starter
Provides:      flight-starter-banner
Conflicts:     flight-starter-banner

%description
Flight Direct branded banner for Flight Starter

%prep
echo "%SHA256SUM0 %SOURCE0" | sha256sum -c -
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

%changelog
* Wed Dec 11 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 2020.1.0
- Updated numbering scheme
- Updated to 2020.1.0
* Fri Oct  4 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 1.1.0
- Initial Package
