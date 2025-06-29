%global ver %{?ver}
%global rel %{?rel}

Name:			wnl
Version:		%{ver}
Release:		%{rel}%{dist}
Summary:		Enables global keyboard shortcuts for your shell
License:		GPL-3.0-or-later
BuildArch:		noarch
URL:			https://codeberg.org/jcgl/wnl
Source0:		%{name}-%{version}.tar.gz

BuildRequires: make

# https://en.opensuse.org/openSUSE:Build_Service_cross_distribution_howto
%if %{defined suse_version}
Requires: util-linux
Requires: procps
Requires: ncurses-utils
%else
Requires: util-linux-core
Requires: procps-ng
Requires: ncurses
%endif

%description
Brings the comfort of IDE-style keyboard shortcuts with the flexibility of the Unix command line.
Bind a command with `wnl`, and trigger the command with `wnlctl`.

%prep
%setup -q

%build
# No building necessary

%install
%make_build install SYSTEM=1 DESTDIR=%{buildroot}

%files
%{_bindir}/wnl
%{_bindir}/wnlctl
%{_datadir}/bash-completion/completions/wnl
%{_datadir}/bash-completion/completions/wnlctl
# these dir directories seem needed to successfully build for opensuse
%dir %{_datadir}/fish/
%dir %{_datadir}/fish/vendor_completions.d/
%{_datadir}/fish/vendor_completions.d/wnl.fish
%{_datadir}/fish/vendor_completions.d/wnlctl.fish
%{_mandir}/man1/wnl.1.gz
%{_mandir}/man1/wnlctl.1.gz
%license LICENSE.md

%changelog
