#!/bin/sh

KEYMAP_PATH=${LOCAL_KEYMAP_PATH}
rm -rf ${KEYMAP_PATH}/compat/japan
rm -rf ${KEYMAP_PATH}/compat/olpc
rm -rf ${KEYMAP_PATH}/compat/pc*
rm -rf ${KEYMAP_PATH}/compat/xtest

rm -rf ${KEYMAP_PATH}/geometry

rm -rf ${KEYMAP_PATH}/keycodes/amiga
rm -rf ${KEYMAP_PATH}/keycodes/ataritt
rm -rf ${KEYMAP_PATH}/keycodes/digital_vndr
rm -rf ${KEYMAP_PATH}/keycodes/empty
rm -rf ${KEYMAP_PATH}/keycodes/evdev
rm -rf ${KEYMAP_PATH}/keycodes/fujitsu
rm -rf ${KEYMAP_PATH}/keycodes/hp
rm -rf ${KEYMAP_PATH}/keycodes/ibm
rm -rf ${KEYMAP_PATH}/keycodes/macintosh
rm -rf ${KEYMAP_PATH}/keycodes/olpc
rm -rf ${KEYMAP_PATH}/keycodes/sgi_vndr
rm -rf ${KEYMAP_PATH}/keycodes/sony
rm -rf ${KEYMAP_PATH}/keycodes/sun
rm -rf ${KEYMAP_PATH}/keycodes/xfree*

rm -rf ${KEYMAP_PATH}/rules/HDR
rm -rf ${KEYMAP_PATH}/rules/base*
rm -rf ${KEYMAP_PATH}/rules/bin
rm -rf ${KEYMAP_PATH}/rules/compat
rm -rf ${KEYMAP_PATH}/rules/evdev.*
rm -rf ${KEYMAP_PATH}/rules/xfree*
rm -rf ${KEYMAP_PATH}/rules/xkb.dtd
rm -rf ${KEYMAP_PATH}/rules/xorg*

./remove_symbols.sh

rm -rf ${KEYMAP_PATH}/types/cancel
rm -rf ${KEYMAP_PATH}/types/caps
rm -rf ${KEYMAP_PATH}/types/default
rm -rf ${KEYMAP_PATH}/types/nokia
