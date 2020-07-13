Name:           alces-flight-release
Version:        2
Release:        1
Summary:        Alces Flight repository configuration

Group:          System Environment/Base
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        https://raw.githubusercontent.com/alces-flight/alces-flight-omnibus-builder/master/LICENSE.txt
Source1:        https://raw.githubusercontent.com/alces-flight/alces-flight-omnibus-builder/builders/alces-flight-release/dist/alces-flight.repo
#Source2:        https://alces-flight.s3-eu-west-1.amazonaws.com/repos/alces-flight-gpg-key

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      redhat-release >= 7

%description
This package contains the Alces Flight repository configuration for yum.

%prep

%setup -q  -c -T
install -pm 644 %{SOURCE0} .
install -pm 644 %{SOURCE1} .

%build

%install
rm -rf $RPM_BUILD_ROOT

#GPG Key
#install -Dpm 644 %{SOURCE2} \
#    $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-ALCES-FLIGHT

# yum
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE1}  \
    $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc LICENSE.txt
%config(noreplace) /etc/yum.repos.d/*
#/etc/pki/rpm-gpg/*

%changelog
* Mon Jul 13 2020 Mark J. Titorenko <mark.titorenko@alces-flight.coom> - 2.0
- Merged all repo files into one master file
- Added el8 support through use of $releasever repo variable
- Reworked URLs
* Thu Oct  3 2019 Rob Brown <rob.brown@alces-flight.com> - 1.0
- Initial Package
