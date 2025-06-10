%global ver %{?ver}
%global rel %{?rel}

Name:           wnl
Version:        %{ver}
Release:        %{rel}%{dist}
Summary:        tools to manage a command line from afar
License:        GPLv3
BuildArch:      noarch

Source0:        %{name}-%{version}.tar.gz

%description
Tools to make global shortcuts for Up+Enter in your shell

%prep
%setup -q

%build
# No building necessary

%install
rm -rf %{buildroot}
install -d %{buildroot}%{_bindir}
install -m 0755 wnl wnlctl %{buildroot}%{_bindir}/

%files
%{_bindir}/wnl
%{_bindir}/wnlctl

%changelog
* Wed Apr 16 2025 j <j@cgl.sh> - 0.1.0-1
- Initial package creation.
