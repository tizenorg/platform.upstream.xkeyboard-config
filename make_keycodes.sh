#!/bin/sh

KEYMAP_FILE_PATH="/usr/share/X11/xkb/tizen_key_layout.txt"
KEYCODES_PATH="./keycodes/"
DEFAULT_KEYCODES_NAME="evdev"
NEW_KEYCODES_NAME="tizen_"${TIZEN_PROFILE}
FULL_KEY_LIST="\/\/ For Tizen Keycodes"
CHANGE_STRING="\/\/ @For Tizen Keycodes@"
PLATFORM_BASE_KEYCODE=8

if [ -e ${KEYMAP_FILE_PATH} ]
then
	echo "${TIZEN_PROFILE} have a key layout file: ${KEYMAP_FILE_PATH}"
else
	echo "${TIZEN_PROFILE} doesn't have a key layout file: ${KEYMAP_FILE_PATH}"
	exit
fi

echo "Generate a tizen keycodes file"

cp ${KEYCODES_PATH}${DEFAULT_KEYCODES_NAME} ${KEYCODES_PATH}${NEW_KEYCODES_NAME}

echo ${KEYCODES_PATH}${NEW_KEYCODES_NAME}

while read KEYNAME KERNEL_KEYCODE KEYBOARD_KEY
do
	[ "$KEYBOARD_KEY" = "keyboard"  ] && continue
	KERNEL_KEYCODE=$(echo $KERNEL_KEYCODE $PLATFORM_BASE_KEYCODE | awk '{print $1 + $2}')
	KEYCODE="${KERNEL_KEYCODE}"
	FULL_KEY_LIST=${FULL_KEY_LIST}"\n\t<I${KEYCODE}>=${KEYCODE}; \/\/ ${KEYNAME}"
done < ${KEYMAP_FILE_PATH}

echo ${FULL_KEY_LIST}

sed -i "s/${CHANGE_STRING}/${FULL_KEY_LIST}/g" ${KEYCODES_PATH}${NEW_KEYCODES_NAME}

sed -i "s/${DEFAULT_KEYCODES_NAME}/${NEW_KEYCODES_NAME}/g" ${KEYCODES_PATH}${NEW_KEYCODES_NAME}
