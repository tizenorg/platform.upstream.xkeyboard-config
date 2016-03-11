%bcond_with x

Name:           xkeyboard-config
Version:        2.13
Release:        0
License:        MIT
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
%if "%{?profile}" == "common"
%else
BuildRequires:  xkb-tizen-data
%endif

%global TZ_SYS_RO_SHARE  %{?TZ_SYS_RO_SHARE:%TZ_SYS_RO_SHARE}%{!?TZ_SYS_RO_SHARE:/usr/share}
%global TZ_SYS_VAR  %{?TZ_SYS_VAR:%TZ_SYS_VAR}%{!?TZ_SYS_VAR:/opt/var}

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
export TIZEN_PROFILE="%{?profile}"
%if "%{?profile}" == "common"
%else

%if %{with x}
export TIZEN_WINDOW_SYSTEM="x11"
%else
export TIZEN_WINDOW_SYSTEM="wayland"
%endif

export TZ_SYS_RO_SHARE="%{TZ_SYS_RO_SHARE}"
./make_keycodes.sh
./make_symbols.sh
%endif

%build
%autogen --with-xkb-rules-symlink=xfree86,xorg \
            --with-xkb-base=%{TZ_SYS_RO_SHARE}/X11/xkb \
            --enable-compat_rules \
            --disable-runtime-deps \
            --disable-xkbcomp-symlink \
            --with-tizen-profile="%{?profile}"
rm -f */*.dir
%__make

%install
%make_install
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb
ln -snf %{_bindir}/xkbcomp %{buildroot}%{_datadir}/X11/xkb/xkbcomp
# Bug 335553
mkdir -p %{buildroot}%{_localstatedir}/lib/xkb/compiled/
ln -snf %{TZ_SYS_VAR}/lib/xkb/compiled/ %{buildroot}%{_datadir}/X11/xkb/compiled
%find_lang %{name}
%fdupes -s %{buildroot}%{_datadir}/X11/xkb
%if "%{?profile}" == "common"
%else
cp -af %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/evdev %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/tizen_"%{?profile}"
mv -f %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/evdev %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/evdev.org
sed -i 's/evdev/tizen_%{?profile}/g' %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/tizen_"%{?profile}"
ln -sf tizen_"%{?profile}" %{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb/rules/evdev
export LOCAL_KEYMAP_PATH=%{buildroot}/%{TZ_SYS_RO_SHARE}/X11/xkb
./remove_unused_files.sh

#for license notification
mkdir -p %{buildroot}/%{TZ_SYS_RO_SHARE}/license
cp -a %{_builddir}/%{buildsubdir}/COPYING %{buildroot}/%{TZ_SYS_RO_SHARE}/license/%{name}
%endif

%files -f %{name}.lang
%manifest %{name}.manifest
%defattr(-,root,root)
%doc AUTHORS README docs/HOWTO.* docs/README.*
%dir %{_localstatedir}/lib/xkb/compiled
%{TZ_SYS_RO_SHARE}/license/%{name}
%{_datadir}/X11/xkb/
%{_datadir}/pkgconfig/*.pc