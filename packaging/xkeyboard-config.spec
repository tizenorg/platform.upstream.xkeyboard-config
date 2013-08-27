# INFO: Package contains data-only, no binaries, so no debuginfo is needed
%define debug_package %{nil}

Summary: X Keyboard Extension configuration data
Name: xkeyboard-config
Version: 2.9
Release: 4
License: MIT
Group: User Interface/X
URL: http://www.freedesktop.org/wiki/Software/XKeyboardConfig

Source: %{name}-%{version}.tar.gz

# Bug 826220 - Tilda is now a dead key (for accented chars)
#Patch01: 0001-Reverting-broken-fix-for-is-keyboard.patch

BuildArch: noarch

BuildRequires: pkgconfig
BuildRequires: xorg-x11-xutils-dev
BuildRequires: xkbcomp
BuildRequires: perl(XML::Parser)
BuildRequires: intltool
BuildRequires: gettext
BuildRequires: automake autoconf libtool pkgconfig
BuildRequires: glib2-devel
BuildRequires: pkgconfig(xproto)
BuildRequires: libX11-devel
BuildRequires: libxslt
Provides:    xkbdata
Requires:    dlogutil

%package -n xkb-data
Summary:    X Keyboard Extension (XKB) configuration data
Group:      System/X11
Requires:	xorg-x11-server-common

%description -n xkb-data
%{summary}

%package -n xkb-data-i18n
Summary:    X Keyboard Extension (XKB) configuration data
Group:      System/X11

%description -n xkb-data-i18n
%{summary}

%description
This package contains configuration data used by the X Keyboard Extension 
(XKB), which allows selection of keyboard layouts when using a graphical 
interface. 

%package devel
Summary: Development files for %{name}
Group: User Interface/X
Requires: %{name} = %{version}-%{release}
Requires: pkgconfig

%description devel
%{name} development package

%prep
%setup -q

%build
%autogen
%configure \
    --enable-compat-rules \
    --with-xkb-base=/etc/X11/xkb --datarootdir=/etc \
    --disable-xkbcomp-symlink \
    --with-xkb-rules-symlink=xfree86,xorg

make %{?jobs:-j%jobs} %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}/usr/share/license
cp -af COPYING %{buildroot}/usr/share/license/%{name}
cp -af COPYING %{buildroot}/usr/share/license/xkb-data
cp -af COPYING %{buildroot}/usr/share/license/xkb-data-i18n
make install DESTDIR=$RPM_BUILD_ROOT INSTALL="install -p"
cp -af %{buildroot}/etc/X11/xkb/rules/evdev %{buildroot}/etc/X11/xkb/rules/tizen_mobile
mv -f %{buildroot}/etc/X11/xkb/rules/evdev %{buildroot}/etc/X11/xkb/rules/evdev.org
sed -i 's/evdev/tizen_mobile/g' %{buildroot}/etc/X11/xkb/rules/tizen_mobile
ln -sf tizen_mobile %{buildroot}/etc/X11/xkb/rules/evdev

%remove_docs

# Remove unnecessary symlink
rm -f $RPM_BUILD_ROOT%{_datadir}/X11/xkb/compiled
%find_lang %{name} 

mkdir -p  %{buildroot}/etc/X11/xkb/
mv %{buildroot}/etc/X11/xkb/rules/base.xml %{buildroot}/etc/X11/xkb/
pushd %{buildroot}
ln -s /etc/X11/xkb/base.xml etc/X11/xkb/rules/base.xml
popd

# Create filelist
{
   FILESLIST=${PWD}/files.list
   pushd $RPM_BUILD_ROOT
   find .%{_datadir}/X11/xkb -type d | sed -e "s/^\./%dir /g" > $FILESLIST
   find .%{_datadir}/X11/xkb -type f | sed -e "s/^\.//g" >> $FILESLIST
   popd
}

%files -f files.list -f %{name}.lang
%manifest xkeyboard-config.manifest
/usr/share/license/%{name}
%defattr(-,root,root,-)
#%doc AUTHORS README NEWS TODO COPYING CREDITS docs/README.* docs/HOWTO.*
/etc/X11/xkb/base.xml
/etc/X11/xkb/rules/base.xml
/etc/X11/xkb/rules/xfree86
/etc/X11/xkb/rules/xfree86.lst
/etc/X11/xkb/rules/xfree86.xml
/etc/X11/xkb/rules/xorg
/etc/X11/xkb/rules/xorg.lst
/etc/X11/xkb/rules/xorg.xml
#%{_mandir}/man7/xkeyboard-config.*

%files devel
%defattr(-,root,root,-)
%{_datadir}/pkgconfig/xkeyboard-config.pc

%files -n xkb-data
%manifest xkb-data.manifest
/usr/share/license/xkb-data
#%defattr(-,root,root,-)
/etc/X11/*

%files -n xkb-data-i18n
%manifest xkb-data-i18n.manifest
/usr/share/license/xkb-data-i18n
#%defattr(-,root,root,-)
/usr/share/locale/*
