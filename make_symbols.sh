#!/bin/sh

if [ "$TZ_SYS_RO_SHARE" = "" ]; then
        TZ_SYS_RO_SHARE="/usr/share"
fi

KEYMAP_FILE_PATH="${TZ_SYS_RO_SHARE}/X11/xkb/tizen_key_layout.txt"
SYMBOLS_PATH="./symbols/inet"
DEFAULT_SYMBOLS_NAME="evdev"
DEFAULT_SYMBOLS_DEFINE="Evdev"
NEW_SYMBOLS_NAME="tizen_"${TIZEN_PROFILE}
DEFAULT_SYMBOLS_SECTION=false
TEMP_SYMBOLS_FILE="./symbols/inet_tizen"
PLATFORM_BASE_KEYCODE=8

if [ -e ${KEYMAP_FILE_PATH} ]
then
	echo "${TIZEN_PROFILE} have a key layout file: ${KEYMAP_FILE_PATH}"
else
	echo "${TIZEN_PROFILE} doesn't have a key layout file: ${KEYMAP_FILE_PATH}"
	exit
fi

echo "Generate a tizen symbol file"

if [ -e ${TEMP_SYMBOLS_FILE} ]
then
	rm ${TEMP_SYMBOLS_FILE}
fi

while read line
do
	if echo ${line} | grep -q ${DEFAULT_SYMBOLS_DEFINE};
	then
		DEFAULT_SYMBOLS_SECTION=true
	fi

	if [ "$DEFAULT_SYMBOLS_SECTION" = true ]
	then
		if [ "$line" = "};" ]
		then
			DEFAULT_SYMBOLS_SECTION=false
		else
			echo "$line" >> ${TEMP_SYMBOLS_FILE}
		fi
	fi
done < ${SYMBOLS_PATH}

echo "" >> ${TEMP_SYMBOLS_FILE}
echo "// Tizen common keys" >> ${TEMP_SYMBOLS_FILE}
while read KEYNAME KERNEL_KEYCODE KEYBOARD_OPT
do
	[[ $KEYBOARD_OPT == *"keyboard"* ]] && continue
	KERNEL_KEYCODE=$(echo $KERNEL_KEYCODE $PLATFORM_BASE_KEYCODE | awk '{print $1 + $2}')
	KEYCODE="${KERNEL_KEYCODE}"
	echo "key <I$KEYCODE>   {     [ ${KEYNAME}     ]     };" >> ${TEMP_SYMBOLS_FILE}
done < ${KEYMAP_FILE_PATH}
echo "};" >> ${TEMP_SYMBOLS_FILE}

sed -i "s/${DEFAULT_SYMBOLS_NAME}/${NEW_SYMBOLS_NAME}/g" ${TEMP_SYMBOLS_FILE}
sed -i 's/Evdev/Tizen/g' ${TEMP_SYMBOLS_FILE}

echo "" >> ${SYMBOLS_PATH}
echo "" >> ${SYMBOLS_PATH}
while read line
do
	echo "$line" >> ${SYMBOLS_PATH}
done < ${TEMP_SYMBOLS_FILE}

rm ${TEMP_SYMBOLS_FILE}
