SUBDIRS = digital_vndr sgi_vndr

keycodesdir = $(xkb_base)/keycodes

keycodes_DATA = \
aliases \
amiga \
ataritt \
empty \
evdev \
fujitsu \
hp \
ibm \
macintosh \
olpc \
sony \
sun \
xfree86 \
xfree98 \
README

if TIZEN_COMMON_PROFILE
else
if KEY_LAYOUT_EXIST
keycodes_DATA += tizen_${tizen_profile}
endif
endif

EXTRA_DIST = $(keycodes_DATA)
