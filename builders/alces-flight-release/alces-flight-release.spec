Name:           alces-flight-release
Version:        1
Release:        1
Summary:        Alces Flight repository configuration

Group:          System Environment/Base
License:        EPL-2.0

URL:            https://alces-flight.com
%undefine _disable_source_fetch
Source0:        https://raw.githubusercontent.com/alces-flight/alces-flight-omnibus-builder/master/LICENSE.txt
%define SHA256SUM0 8c349f80764d0648e645f41ef23772a70c995a0924b5235f735f4a3d09df127c
Source1:        https://alces-flight.s3-eu-west-1.amazonaws.com/repos/alces-flight/alces-flight.repo
%define SHA256SUM1 eef326f52cb3899837136753c3380602f9594c8e35be1d593c148be2021b3572
Source2:        https://alces-flight.s3-eu-west-1.amazonaws.com/repos/alces-flight-dev/alces-flight-dev.repo
%define SHA256SUM2 3caca02c70445670432de4e09108824e6dc98cd775d23c80a30be6b531d6ec67
#Source3:        https://alces-flight.com/RPM-GPG-KEY-ALCES-FLIGHT

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:     noarch
Requires:      redhat-release >= 7
<
%description
This package contains the Alces Flight repository configuration for yum.

%prep
echo "%SHA256SUM0 %SOURCE0" | sha256sum -c -
echo "%SHA256SUM1 %SOURCE1" | sha256sum -c -
echo "%SHA256SUM2 %SOURCE2" | sha256sum -c -

%setup -q  -c -T
install -pm 644 %{SOURCE0} .
install -pm 644 %{SOURCE1} .
install -pm 644 %{SOURCE2} .
sed -i 's/enabled=1/enabled=0/g' %{SOURCE2}

%build


%install
rm -rf $RPM_BUILD_ROOT

#GPG Key
#install -Dpm 644 %{SOURCE3} \
#    $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-ALCES-FLIGHT

# yum
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE1} %{SOURCE2}  \
    $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc LICENSE.txt
%config(noreplace) /etc/yum.repos.d/*
#/etc/pki/rpm-gpg/*


%changelog
* Thu Oct  3 2019 Rob Brown <rob.brown@alces-flight.com> - 1.0
- Initial Package
