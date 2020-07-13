Name:           flight-plugin-manual-pam
Version:        %{_flight_pkg_version}
Release:        %{_flight_pkg_rel}%{?dist}
Summary:        PAM module using the Alces Flight Platform for authentication
Group:          OpenFlight/Environment
License:        EPL-2.0

URL:            https://github.com/alces-flight/%{_flight_repo_name}
%undefine _disable_source_fetch
Source0:        https://github.com/alces-flight/%{_flight_repo_name}/archive/%{_flight_repo_tag}.tar.gz
Source1:        https://raw.githubusercontent.com/alces-flight/alces-flight-omnibus-builder/flight-pam/builders/flight-plugin-pam/dist/etc/pam.d/flight
BuildRoot:      %{_tmppath}/%{_flight_repo_name}-%{_flight_repo_tag}-%{release}-root-%(%{__id_u} -n)
BuildArch:      x86_64
BuildRequires:  libcurl-devel pam-devel
Provides:       flight-pam-system-1.0
Provides:       flight-plugin-pam
Conflicts:      flight-plugin-system-pam
Requires:       libcurl pam

%description
PAM module using the Alces Flight Platform for authentication

%prep
%setup -q -n %{_flight_repo_name}-%{_flight_repo_tag}
install -pm 644 %{SOURCE1} .

%build
make

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/flight/etc/pam.d
install -m 644 %{SOURCE1} $RPM_BUILD_ROOT/opt/flight/etc/pam.d/flight
mkdir -p $RPM_BUILD_ROOT/opt/flight/usr/lib/security
make install PREFIX=$RPM_BUILD_ROOT/opt/flight
mkdir -p $RPM_BUILD_ROOT/opt/flight/opt/flight-pam/
for a in LICENSE.txt README.md ; do
  install -m 644 ${a} $RPM_BUILD_ROOT/opt/flight/opt/flight-pam/${a}
done

%clean
make clean

%files
/opt/flight/etc/pam.d/flight
/opt/flight/usr/lib/security/pam_flight.so
/opt/flight/opt/flight-pam/LICENSE.txt
/opt/flight/opt/flight-pam/README.md

%changelog
* Wed Jul 08 2020 Ben Armston <ben.armston@alces-flight.com> - 0.1.0-1
- Initial Package
