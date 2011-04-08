#!/bin/bash -eu
#
# Author: Anton Stoychev <antitoxic@gmail.com>
#

###################### DIRS #############################

input_existing_dir_with_default()
{
	defaultDirPath=${1}
	inputPromptMsg=${2}
	
	echo -e $inputPromptMsg
	echo "(default: $defaultDirPath )"
	read dirPath
	if [ -z "$dirPath" ]
	then
		dirPath=$defaultDirPath
	fi
	get_existing_dir $dirPath
}

input_existing_dir()
{
	inputPromptMsg=${1}
	
	echo -e $inputPromptMsg:
	read dirPath
	trim_right $dirPath '\/'
	dirPath=$RET
	get_existing_dir $dirPath
}


get_existing_dir()
{
	local warningMsg="Such directory does not exist. Provide an existing directory: "
	local OK=0
	
	if [ $# -eq 0 ]
	then
		echo $warningMsg
	else 
		dirPath="${1}"
		if ! [ -d "$dirPath" ]
		then
			echo $warningMsg
		else 
		OK=1
		fi
	fi
	if [ $OK -eq 0 ]
	then
		while read dirPath
		do
			if ! [ -d "$dirPath" ]
			then
				echo $warningMsg
			else
				break
			fi
		done
	fi
	RET=$dirPath
}

copy_dir_contents_to()
{
	#--update copy only if destination is older
	from=$1
	to=$2
	# cp -R "$from" "$to"
	rsync -a "$1/" "$2"
}

touch_dir() {
	dirPath=$1
	mkdir -p "$dirPath"
}