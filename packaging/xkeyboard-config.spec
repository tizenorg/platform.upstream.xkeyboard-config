Name:           xkeyboard-config
Version:        2.7
Release:        0
License:        GPL-2.0+ ; LGPL-2.1+ ; MIT
Summary:        The X Keyboard Extension
Url:            http://www.freedesktop.org/Software/XKeyboardConfig
Group:          System/X11/Utilities
Source:         http://xorg.freedesktop.org/releases/individual/data/%{name}-%{version}.tar.bz2
BuildRequires:  fdupes
BuildRequires:  intltool
BuildRequires:  perl-XML-Parser
BuildRequires:  pkg-config
BuildRequires:  xkbcomp
BuildRequires:  pkgconfig(xorg-macros) >= 1.12
Requires:       xkbcomp
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

%build
%configure --with-xkb-rules-symlink=xfree86,xorg \
            --with-xkb-base=/usr/share/X11/xkb \
            --enable-compat_rules \
            --disable-runtime-deps \
            --disable-xkbcomp-symlink
rm -f */*.dir
make

%install
%make_install
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb
ln -snf /usr/bin/xkbcomp %{buildroot}/usr/share/X11/xkb/xkbcomp
# Bug 335553
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb/compiled/
ln -snf /var/lib/xkb/compiled/ %{buildroot}/usr/share/X11/xkb/compiled
%find_lang %{name}
%fdupes -s %{buildroot}/usr/share/X11/xkb

%files -f %{name}.lang
%defattr(-,root,root)
%doc AUTHORS COPYING README docs/HOWTO.* docs/README.*
%dir %{_localstatedir}/lib/xkb
%dir %{_localstatedir}/lib/xkb/compiled
/usr/share/X11/xkb/
%{_datadir}/pkgconfig/*.pc

%changelog
