%bcond_with x

Name:           xkeyboard-config
Version:        2.12
Release:        0
License:        GPL-2.0+ and LGPL-2.1+ and MIT
Summary:        The X Keyboard Extension
Url:            http://www.freedesktop.org/Software/XKeyboardConfig
Group:          System/Utilities
Source:         http://xorg.freedesktop.org/releases/individual/data/%{name}-%{version}.tar.bz2
Source1001:     xkeyboard-config.manifest
BuildRequires:  fdupes
BuildRequires:  intltool
BuildRequires:  perl-XML-Parser
BuildRequires:  pkg-config
%if %{with x}
BuildRequires:  xkbcomp
Requires:       xkbcomp
%endif
BuildRequires:  pkgconfig(xorg-macros) >= 1.12
Provides:       XFree86:/etc/X11/xkb/symbols/us
Provides:       xorg-x11:/etc/X11/xkb/symbols/us
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
Requires(pre):  /usr/bin/ln
Requires(pre):  /usr/bin/rm

%description
The X Keyboard Extension essentially replaces the core protocol
definition of keyboard. The extension makes possible to clearly and
explicitly specify most aspects of keyboard behaviour on per-key basis
and to more closely track the logical and physical state of the
keyboard. It also includes a number of keyboard controls designed to
make keyboards more accessible to people with physical impairments.

%prep
%setup -q
cp %{SOURCE1001} .

%build
%autogen --with-xkb-rules-symlink=xfree86,xorg \
            --with-xkb-base=/usr/share/X11/xkb \
            --enable-compat_rules \
            --disable-runtime-deps \
            --disable-xkbcomp-symlink
rm -f */*.dir
%__make

%install
%make_install
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb
ln -snf %{_bindir}/xkbcomp %{buildroot}%{_datadir}/X11/xkb/xkbcomp
# Bug 335553
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb/compiled/
ln -snf /var/lib/xkb/compiled/ %{buildroot}%{_datadir}/X11/xkb/compiled
%find_lang %{name}
%fdupes -s %{buildroot}%{_datadir}/X11/xkb

%files -f %{name}.lang
%manifest %{name}.manifest
%defattr(-,root,root)
%doc AUTHORS README docs/HOWTO.* docs/README.*
%license COPYING
%dir %{_localstatedir}/lib/xkb/compiled
%{_datadir}/X11/xkb/
%{_datadir}/pkgconfig/*.pc
