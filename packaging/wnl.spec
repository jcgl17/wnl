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
Enables global keyboard shortcuts for your shell. Brings the comfort of IDE-style keyboard shortcuts with the flexibility of the Unix command line.

%prep
%setup -q

%build
# No building necessary

%install
rm -rf %{buildroot}
install -d %{buildroot}%{_bindir}
install -m 0755 wnl wnlctl %{buildroot}%{_bindir}/
install -d %{buildroot}%{_datadir}/fish/vendor_completions.d
install -m 0644 completions/*.fish %{buildroot}%{_datadir}/fish/vendor_completions.d/
install -d %{buildroot}%{_datadir}/bash-completion/completions
install -m 0644 completions/wnl.bash %{buildroot}%{_datadir}/bash-completion/completions/wnl
install -m 0644 completions/wnlctl.bash %{buildroot}%{_datadir}/bash-completion/completions/wnlctl

%files
%{_bindir}/wnl
%{_bindir}/wnlctl
# these dir directories seem needed to successfully build for opensuse
%dir %{_datadir}/fish/
%dir %{_datadir}/fish/vendor_completions.d/
%{_datadir}/fish/vendor_completions.d/wnl.fish
%{_datadir}/fish/vendor_completions.d/wnlctl.fish
%{_datadir}/bash-completion/completions/wnl
%{_datadir}/bash-completion/completions/wnlctl

%changelog
* Wed Apr 16 2025 j <j@cgl.sh> - 0.1.0-1
- Initial package creation.
