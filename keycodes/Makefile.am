keycodesdir = $(xkb_base)/keycodes

keycodes_DATA = \
aliases \
evdev \
README

if TIZEN_COMMON_PROFILE
else
if KEY_LAYOUT_EXIST
keycodes_DATA += tizen_${tizen_profile}
endif
endif

EXTRA_DIST = $(keycodes_DATA)
