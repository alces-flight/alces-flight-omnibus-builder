Name:           flight-direct-flight-starter-banner
Version:        1
Release:        1
Summary:        Flight Direct branded banner for Flight Starter

Group:          OpenFlight/Environment
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        %{name}-%{version}.tar.gz
%define SHA256SUM0 673196516a7f0aea27f495eda08728b656491965e53a49ea7f2ca797dc396fdf

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
* Fri Oct  4 2019 Mark J. Titorenko <mark.titorenko@alces-flight.com> - 1.1.0
- Initial Package
