#!/bin/sh

RULE_FILE=${RULE_FILE_PATH}
XKB_FILES_PATH=${LOCAL_KEYMAP_PATH}"/symbols/"
TEMP_SAVE_FILE="./tmp.txt"
TEMP_UNDELETE_LIST_FILE="./tmp_list.txt"
TEMP_UNDELETE_LIST_FOLDER="./tmp_folder.txt"
SUPPORTED_LAYOUTS=""
ALREADY_LAYOUT=0
LAYOUTS=""
END_FLAG=0
UNDELETE_LAYOUTS=""

START_POINT=0
SECTION_FLAG=0
DEEP_FIND_COUNT=0

function Add_Layout()
{
	NEW_STRING=$1"("$2")"

	[[ "${SUPPORTED_LAYOUTS}" == *"${NEW_STRING}"* ]] && ALREADY_LAYOUT=1

	if [ "$ALREADY_LAYOUT" == "1" ]; then
		return
	fi

	SUPPORTED_LAYOUTS=$SUPPORTED_LAYOUTS$NEW_STRING","
}

function Search_Symbol()
{
	STRING=$1

	if [[ "${STRING}" == *"include \""* ]]; then
		HAVE_SECTION_FLAG=0
		NEW_STRING=${STRING#include \"}
		NEW_STRING=${NEW_STRING%\"}

		[[ "${NEW_STRING}" == *"("* ]] && HAVE_SECTION_FLAG=1

		if [ "${HAVE_SECTION_FLAG}" == "1" ]; then
			NEW_LAYOUT=${NEW_STRING%%(*}
			SECTION=${NEW_STRING#$NEW_LAYOUT}
			SECTION=${SECTION#(}
			SECTION=${SECTION%)}

			Find_Layout $NEW_LAYOUT $SECTION
			SECTION_FLAG=$DEEP_FIND_COUNT
			START_POINT=1
		else
			NEW_LAYOUT=$NEW_STRING
			Find_Default_Layout $NEW_LAYOUT
			SECTION_FLAG=$DEEP_FIND_COUNT
			START_POINT=1
		fi
	fi

}

function Find_Layout()
{
	LAYOUT=$1
	LAYOUT_FILE_PATH=${XKB_FILES_PATH}${LAYOUT}

	DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT+1)))

	if [ ! -e ${LAYOUT_FILE_PATH} ]; then
		return
	fi

	Add_Layout $1 $2

	if [ "$ALREADY_LAYOUT" == "1" ]; then
		ALREADY_LAYOUT=0
		DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT-1)))
		return
	fi

	FIND_LAYOUT_FLAG=0
	SECTION_FLAG=$DEEP_FIND_COUNT
	START_POINT=0

	while read STRING
	do
		[[ "${STRING}" == *"xkb_symbols \"$2\""* ]] && FIND_LAYOUT_FLAG=1

		if [ "$FIND_LAYOUT_FLAG" == "1" ]; then
			[[ "${STRING}" == *"{"* ]] && START_POINT=$(echo $START_POINT "1" | awk '{print $1 + $2}')
			[[ "${STRING}" == *"}"* ]] && START_POINT=$(echo $START_POINT "1" | awk '{print $1 - $2}')

			if [ "${SECTION_FLAG}" == $DEEP_FIND_COUNT ]; then
				if [ "${START_POINT}" == 1 ]; then
					SECTION_FLAG=$(echo $(($SECTION_FLAG+1)))
				fi
			fi

			Search_Symbol "$STRING"

			if [ "${SECTION_FLAG}" != $DEEP_FIND_COUNT ]; then
				if [ "${START_POINT}" == "0" ]; then
					break
				fi
			fi
		fi
	done < ${LAYOUT_FILE_PATH}
	DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT-1)))
}

function Find_Default_Layout()
{
	LAYOUT=$1
	LAYOUT_FILE_PATH=${XKB_FILES_PATH}${LAYOUT}
	DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT+1)))

	INCLUDE_CNT=0
	PREV_INCLUDE_CNT=$INCLUDE_CNT

	STRING_DEFAULT_LINE=0
	GET_DEFAULT_SYMBOL_LAYOUT_FLAG=0

	START_POINT=0
	SECTION_FLAG=$DEEP_FIND_COUNT

	while read STRING
	do
		[[ "${STRING}" == *"default"* ]] && STRING_DEFAULT_LINE=1

		if [ $STRING_DEFAULT_LINE == 1 ]; then
			DEFAULT_SYMBOL_LAYOUT="default"

			[[ "${STRING}" == *"{"* ]] && START_POINT=$(echo $START_POINT "1" | awk '{print $1 + $2}')
			[[ "${STRING}" == *"}"* ]] && START_POINT=$(echo $START_POINT "1" | awk '{print $1 - $2}')

			if [ "${SECTION_FLAG}" == $DEEP_FIND_COUNT ]; then
				if [ "${START_POINT}" == 1 ]; then
					SECTION_FLAG=$(echo $(($SECTION_FLAG+1)))
				fi
			fi

			if [[ "${STRING}" == *"xkb_symbols"* ]]; then
				GET_DEFAULT_SYMBOL_LAYOUT_FLAG=1
			fi


			if [ "$GET_DEFAULT_SYMBOL_LAYOUT_FLAG" == "1" ]; then
				DEFAULT_SYMBOL_LAYOUT=${STRING#xkb_symbols \"}
				DEFAULT_SYMBOL_LAYOUT=${DEFAULT_SYMBOL_LAYOUT%\"*}
				Add_Layout $1 $DEFAULT_SYMBOL_LAYOUT
				if [ "$ALREADY_LAYOUT" == "1" ]; then
					ALREADY_LAYOUT=0
					DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT-1)))
					return
				fi
				GET_DEFAULT_SYMBOL_LAYOUT_FLAG=0
			fi

			Search_Symbol "$STRING"

			if [ "${SECTION_FLAG}" != $DEEP_FIND_COUNT ]; then
				if [ "${START_POINT}" == "0" ]; then
					break
				fi
			fi
		fi
	done < ${LAYOUT_FILE_PATH}
	DEEP_FIND_COUNT=$(echo $(($DEEP_FIND_COUNT-1)))
}

BASE_LAYOUTS=""
DEFAULT_MODEL=""
DEFAULT_LAYOUT=""

if [ -e ${RULE_FILE} ]
then
	while read STRING
	do
		if [[ $STRING == *"model="* ]]; then
			DEFAULT_MODEL=${STRING#*=}
		fi
		if [[ $STRING == *"layout="* ]]; then
			DEFAULT_LAYOUT=${STRING#*=}
		fi
		[[ $STRING != *"supported_layout"* ]] && continue
		BASE_LAYOUTS=${STRING#supported_layouts=}
		echo "Support language: "$BASE_LAYOUTS
	done < ${RULE_FILE}

	echo "Default Model/Layout: "$DEFAULT_MODEL"/"$DEFAULT_LAYOUT

	LAYOUTS=$BASE_LAYOUTS
	if [[ "$DEFAULT_MODEL" == *"pc"* ]]; then
		LAYOUTS=$LAYOUTS", pc"
	fi
	if [[ "$LAYOUTS" != *$DEFAULT_LAYOUT* ]]; then
		LAYOUTS=$LAYOUTS", "$DEFAULT_LAYOUT
	fi

	for ((;;)); do
		SUB_LAYOUT=${LAYOUTS%%,*}
		LAYOUTS=${LAYOUTS#$SUB_LAYOUT}
		LAYOUTS=${LAYOUTS#,}

		START_POINT=0
		SECTION_FLAG=0
		DEEP_FIND_COUNT=0

		Find_Default_Layout $SUB_LAYOUT

		echo $SUPPORTED_LAYOUTS

		if [ ! "$LAYOUTS" ]; then
			break
		fi
	done

	echo "Supported layouts: "$SUPPORTED_LAYOUTS
	if [ -e ${TEMP_UNDELETE_LIST_FILE} ]; then
		rm $TEMP_UNDELETE_LIST_FILE
	fi

	for ((;;)); do
		SUB_LAYOUT=${SUPPORTED_LAYOUTS%%(*}

		HAVE_UNDELETE_LAYOUT_FLAG=0

		[[ $UNDELETE_LAYOUTS == *"$SUB_LAYOUT"* ]] && HAVE_UNDELETE_LAYOUT_FLAG=1

		if [ "$HAVE_UNDELETE_LAYOUT_FLAG" == "0" ]; then
			UNDELETE_LAYOUTS=$UNDELETE_LAYOUTS$SUB_LAYOUT" "
			echo $SUB_LAYOUT >> $TEMP_UNDELETE_LIST_FILE
		fi

		SUPPORTED_LAYOUTS=${SUPPORTED_LAYOUTS#$SUB_LAYOUT}
		SUPPORTED_LAYOUTS=${SUPPORTED_LAYOUTS#*,}
		if [ ! "$SUPPORTED_LAYOUTS" ];then
			break
		fi
	done
fi

touch $TEMP_SAVE_FILE
touch $TEMP_UNDELETE_LIST_FILE
touch $TEMP_UNDELETE_LIST_FOLDER

if [[ $UNDELETE_LAYOUTS != *"inet"* ]]; then
	UNDELETE_LAYOUTS=$UNDELETE_LAYOUTS" inet"
	echo "inet" >> $TEMP_UNDELETE_LIST_FILE
fi

while read UNDELETE_LIST
do
	if [[ "$UNDELETE_LIST" == *"/"* ]]; then
		SUB_FOLDER=$UNDELETE_LIST
		for ((;;)); do
			SUB_FOLDER=${SUB_FOLDER%/*}
			echo $XKB_FILES_PATH$SUB_FOLDER >> $TEMP_UNDELETE_LIST_FOLDER

			[[ "$SUB_FOLDER" != *"/"* ]] && break
		done
	fi
done < $TEMP_UNDELETE_LIST_FILE


echo "Undeleted layouts: "$UNDELETE_LAYOUTS
UNDELETE_SYMBOL_FLAG=0

find $XKB_FILES_PATH > $TEMP_SAVE_FILE
while read SYMBOL_FILES
do
	echo "$SYMBOL_FILES"
	if [ -d $SYMBOL_FILES ]; then
		if [[ $SYMBOL_FILES == $XKB_FILES_PATH ]]; then
			continue
		fi
		UNDELETE_FOLDER_FLAG=0
		while read UNDELETE_FOLDER
		do
			if [[ $SYMBOL_FILES == $UNDELETE_FOLDER ]]; then
				UNDELETE_FOLDER_FLAG=1
				break
			fi
		done < $TEMP_UNDELETE_LIST_FOLDER
		if [[ "$UNDELETE_FOLDER_FLAG" == "1" ]]; then
			continue
		fi
	fi
	SYMBOL_FILES=${SYMBOL_FILES#$XKB_FILES_PATH}
	while read UNDELETE_LIST
	do
		if [[ "$UNDELETE_LIST" == $SYMBOL_FILES ]]; then
			UNDELETE_SYMBOL_FLAG=1
			break
		fi
	done < $TEMP_UNDELETE_LIST_FILE

	if [ "$UNDELETE_SYMBOL_FLAG" == "0" ]; then
		rm -rf $XKB_FILES_PATH$SYMBOL_FILES
	fi
	UNDELETE_SYMBOL_FLAG=0
done < $TEMP_SAVE_FILE

rm $TEMP_SAVE_FILE
rm $TEMP_UNDELETE_LIST_FILE
rm $TEMP_UNDELETE_LIST_FOLDER
