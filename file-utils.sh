#!/bin/bash -eu
#
# Author: Anton Stoychev <antitoxic@gmail.com>
#

###################### FILE #############################

read_file() 
{
	filePath=${1}
	
	file=""
	while read line
	do
		file="$file\n$line"
	done < "$filePath"
	file="$file\n$line"
	replace_first "$file" '\\n'
	file=$RET
	
	RET=$file
}

get_existing_file_path() 
{
	local warningMsg="Such file does not exist. Provide an existing file path: "
	local SILENT=0
	local OK=0
	local filePath=
	while getopts "f:s" OPTION
	do
		 case $OPTION in
			 f)
				 filePath=$OPTARG
				 ;;
			 s)
				 SILENT=1
				 ;;
		 esac
	done
	if [ -z $filePath ]
	then
		if  [ $SILENT -eq 0 ]
		then
			echo $warningMsg
		fi
	else 
		if ! [ -f "$filePath" ]
		then
			echo $warningMsg
		else 
		OK=1
		fi
	fi
	if [ $OK -eq 0 ]
	then
		while read filePath
		do
			if ! [ -f "$filePath" ]
			then
				echo $warningMsg
			else
				break
			fi
		done
	fi
	RET=$filePath
}

input_existing_file_path() 
{
	inputPromptMsg=${1}
	echo -e $inputPromptMsg:
	#get_existing_file_path saves the output in $RET
	get_existing_file_path -s
}

get_existing_file() 
{
	inputPromptMsg=${1}
	input_existing_file_path $inputPromptMsg
	#input_existing_file_path saves the output in $RET
	filePath=$RET
	read_file $filePath
}

get_file() 
{
	inputPromptMsg=${1}
	echo -e $inputPromptMsg:
	read filePath
	read_file $filePath
}

get_file_path_with_default() 
{
	defaultFilePath=${1}
	inputPromptMsg=${2}
	
	echo -e $inputPromptMsg
	echo "(default: $defaultFilePath )"
	
	while read filePath
	do
		if [ -z "$filePath" ]
		then
			filePath=$defaultFilePath
			break
		else
			if ! [ -f "$filePath" ]
			then
				echo "Such file does not exist. Try typing it again: "
			fi
		fi
	done
	RET=$filePath
}

get_file_with_default_path() 
{
	defaultFilePath=${1}
	inputPromptMsg=${2}
	
	echo -e $inputPromptMsg
	echo "(default: $defaultFilePath )"
	
	while read filePath
	do
		if [ -z "$filePath" ]
		then
			filePath=$defaultFilePath
			break
		else
			if ! [ -f "$filePath" ]
			then
				echo "Such file does not exist. Try typing it again: "
			fi
		fi
	done
	read_file $filePath
}

overwrite_save_file() 
{
	filePath=$1
	data=$2
	sudo echo -e "$2" > $1
}


add_save_file() 
{
	filePath=$1
	data=$2
	sudo echo -e "$2" >> $1
}


make_symlink() 
{
	from=$1
	to=$2
	sudo ln -s $1 $2
}


make_shortcut() 
{
	from=$1
	to=$2
	make_symlink $1 $2
}


copy_file() 
{
	from=$1
	to=$2
	cp $1 $2
}

# cp -R "$from" "$to"