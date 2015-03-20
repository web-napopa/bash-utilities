#!/bin/bash -eu
#
# Author: Anton Stoychev <antitoxic@gmail.com>
#

UTILS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $UTILS_DIR/file-utils.sh
source $UTILS_DIR/dir-utils.sh

usage()
{
    info "* Copyright (C) Anton Stoychev <antitoxic@gmail.com> 2010
* Usage: Transforms Ubuntu into usable web develeopment workstation."
    exit 1
}
info()
{
    cat << EOF
----------------------------
*
${1}
*
----------------------------
EOF
}

debug_print()
{
    [ ${DEBUG} -eq 1 ] && echo "$*"
}

debug_wait_for_enter()
{
    [ ${DEBUG} -eq 1 ] && echo "Press Enter..." && read ENTER
}
retry_command()
{
    # $1 = number of retries
    # $2 = sleep between retries
    # $* = command to execute

    ROUND=0
    MAX=${1}
    SLEEP=${2}
    shift 2

    while [ ${ROUND} -lt ${MAX} ]
    do
        ${*}
        RET=$?
        [ ${RET} -eq 0 ] && break
        ROUND=`expr ${ROUND} + 1`
        if [ ${ROUND} -lt ${MAX} ]; then
             echo ""
             echo "Retries left `expr ${MAX} - ${ROUND}`"
             echo "Retrying in ${SLEEP} sec."
             echo ""
             sleep ${SLEEP}
             debug_wait_for_enter
        fi
    done
}

install_apt()
{
    # $* = packages to install

    # Sanity check
    P=
    for i in $*
    do
        if [ ! -z "`apt-cache show ${i} 2> /dev/null`" ]; then
            P="${P} ${i}"
        else
            echo "WARNING: ${i} not found"
        fi
    done

    # Download all missing debs (try max 10 times)
    retry_command 10 5 sudo apt-get --download-only --force-yes -y install ${P}
    if [ ${RET} -ne 0 ]; then
        echo ""
        echo "Program aborted due to fetch failures."
        echo ""
        exit 1
    fi
    sudo apt-get -y install ${P}
}


function remove_apt_source_duplicates() {
finddupes=$(unset flist; declare -A flist
while read -r sum fname; do
    if [[ ${flist[$sum]} ]]; then
        printf 'sudo rm -- "%s" # Same as >%s<\n' "$fname" "${flist[$sum]}" 
    else
        flist[$sum]="$fname"
    fi
done <  <(find /etc/apt/sources.list.d/ -name "*.list" -exec sha256sum {} +)  >/tmp/.rmdups)

if [[ -s /tmp/.rmdups ]]; then
	chmod +x /tmp/.rmdups
	sudo bash /tmp/.rmdups 
        sudo rm /tmp/.rmdups 
	update_apt
fi
}
function remove_apt_source() {
	subject=${1}
	subject=`echo $subject | sed 's/\./\\\\./g'`
	subject=`echo $subject | sed 's/\?/\\\\?/g'`
	FILES=`grep -l '^[^#]*'$subject /etc/apt/sources.list.d/*.list`
	for f in $FILES
	do
	  string=$RET
	  replacement=''
	  RET=`sed -e "s@^[^#]*$subject.*@$replacement@" $f`
	  #overwrite_save_file "$filePath" "$RET"
	  overwrite_save_file "$f" "$RET"
	done
}


function add_apt_source() {
	echo -e ${1} >/tmp/${2}.list
	sudo cp /tmp/${2}.list /etc/apt/sources.list.d/
	rm /tmp/${2}.list
}

function wget_apt_key() {
	wget ${1} --output-document="/tmp/apt_key"
	apt-key add /tmp/apt_key
}


remove_apt()
{
    # $* = packages to remove

    sudo apt-get -y remove --purge $*
}


update_apt()
{
    # Download package indices (try max 10 times)
    retry_command 10 30 sudo apt-get update
    if [ ${RET} -ne 0 ]; then
        echo ""
        echo "Program aborted due to repository failures."
        echo ""
        exit 1
    fi
}

upgrade_apt()
{

    sudo apt-get -y upgrade
}

add_ppa_repository()
{
   add-apt-repository ppa:${1}
}


isset() {
	if [ -n "${1+x}" ]
	then
		return 0
	fi
	return 1
}
replace_all() 
{
	string=$1
	subject=$2
	if [ -n "${3+x}" ]
	then
		replacement=$3
	else
		replacement=""
	fi
	RET=${string//$subject/$replacement}
}
replace_first() 
{
	string=$1
	subject=$2
	if [ -n "${3+x}" ]
	then
		replacement=$3
	else
		replacement=""
	fi
	RET=${string/$subject/$replacement}
}



# 8d	Delete 8th line of input.
# /^$/d	Delete all blank lines.
# 1,/^$/d	Delete from beginning of input up to, and including first blank line.
# /Jones/p	Print only lines containing "Jones" (with -n option).
# s/Windows/Linux/	Substitute "Linux" for first instance of "Windows" found in each input line.
# s/BSOD/stability/g	Substitute "stability" for every instance of "BSOD" found in each input line.
# s/ *$//	Delete all spaces at the end of every line.
# s/00*/0/g	Compress all consecutive sequences of zeroes into a single zero.
# /GUI/d	Delete all lines containing "GUI".
# s/GUI//g	Delete all instances of "GUI", leaving the remainder of each line intact.

#replace comments with empty line
# sed -e 's/#\(.*\)/\1/' ./data
#remove empty lines
# sed -e '/^$/d' ./data

#replace comments with empty line and then remove all empty lines
# ";" acts like a separator
# sed -e 's/#.*//;/^$/d' ./data


# the following symbols must be escaped for subject and replacement input:
# [ ] \ / ? * ^ $
replace_string_line_containing() {
	string=$1
	subject=$2
	if [ -n "${3+x}" ]
	then
		replacement=$3
	else
		replacement=""
	fi
	if [ ${subject:0:1} != '^' ]
	then
		subject=".*"$subject
	fi
	if [ ${subject:${#subject}-1:1} != '^' ]
	then
		subject=$subject".*"
	fi
	
	RET=`echo -e $string | sed -e "s/$subject/$replacement/"`
}

# the following symbols must be escaped for subject and replacement input:
# [ ] \ / ? * ^ $
replace_file_line_containing() {
	filePath=$1
	subject=$2
	
	if [ -n "${3+x}" ]
	then
		replacement=$3
	else
		replacement=""
	fi
	if [ ${subject:0:1} != '^' ]
	then
		subject=".*"$subject
	fi
	if [ ${subject:${#subject}-1:1} != '$' ]
	then
		subject=$subject".*"
	fi
	RET=`sed -e "s/$subject/$replacement/" $filePath`
}



replace_ini_entry()
{
	# searchQuery=$2
	# searchQueryEscaped=$3
	# replaceRaw=$4
	# replaceEscaped=$5
	
	SHORTOPTS="f:q:s:r:a:"
	LONGOPTS="file:,search-raw:,search-escaped:,replacement-raw:, replacement-escaped:"
	eval set -- `getopt --options $SHORTOPTS --longoptions $LONGOPTS -- "$@" `

	local searchEscaped=
	local replacementEscaped=
	while [ -n "${1+x}" ]; do
	   case $1 in
		  -f|--file)
				shift
				filePath=$1
			 ;;
		  -q|--search-raw)
				shift
				searchRaw=$1
			 ;;
		  -s|--search-escaped)
				shift
				searchEscaped=$1
			 ;;
		  -r|--replacement-raw)
				shift
				replacementRaw=$1
			 ;;
		  -a|--replacement-escaped)
				shift
				replacementEscaped=$1
			 ;;
	   esac
	   shift
	done
	if [ -z "$searchEscaped" ]
	then
		searchEscaped=$searchRaw
	fi
	if [ -z "$replacementEscaped" ]
	then
		replacementEscaped=$replacementRaw
	fi
	updatedLine="memory_limit = 128M"
	if `grep -q "^[ \t;#]*$searchRaw" $filePath`
	# grep -q doesnt output, only get return value: whether there is matches or not
	then
		#exists > replace it
		#replace line but save inline comments
		replace_file_line_containing "$filePath" "^[ \t;#]*$searchEscaped\([^#;]\+\)\?\([#;].*\)\?.*$" "$replacementEscaped\2"
		overwrite_save_file "$filePath" "$RET"
	else
		#doesnt exist > add it
		add_save_file "$filePath" "\n$replacementRaw"
	fi
	
}

fix_ini_file_comments()
{
	filePath=$1
	updated=`sed -e "s/^#\(.*\)$/;\1/" $filePath`
	RET=$updated
	overwrite_save_file "$filePath" "$updated"
}

input_pass() 
{
	promptMsg=${1}
	echo $promptMsg
	while read -s var; do
		if [ -z "$var" ]
		then
			echo "It cannot be empty. Try again:"
		else
			RET=$var
			break
		fi
	done
}
input_nonempty() 
{
	promptMsg=$1
	echo promptMsg
	while read var; do
		if [ -z "$var" ]
		then
			echo "It cannot be empty. Try again:"
		else
			RET=$var
			break
		fi
	done
}

strip_left_up_to() {
	string=$1
	delimiter=$2
	RET=${string#*$delimiter}
}

strip_right_up_to() {
	string=$1
	delimiter=$2
	RET=${string%$delimiter*}
}
trim_right() {
	string=$1
	trimChars=$2
	RET=`echo -e $string | sed -e "s/[$trimChars]*$//"`
}

update_global_commands_paths()
{
	update_PATH_entry $1 $2
}
update_PATH_entry() 
{
	search=$1
	replacement=$2
	echo $PATH
	temp=`echo -e $PATH | sed -e "s/^[^:]*$search[^:]*:/$replacement:/"`
	echo -e $temp | sed -e "s/:[^:]*$search[^:]*/:$replacement/g"
}

restart_apache()
{
	sudo /etc/init.d/apache2 restart
}

input_two_choice() {
	question=$1
	option1=$2
	option2=$3
	echo $1
	echo "'$2' or '$3'"
	if [ -n "${4+x}" ]
	then
		default=$4
	else
		default=$2
	fi
	echo "(default is $default)"
	while read answer
	do
		if ! [ -z "$answer" ] && [ "$answer" != "$option1" ] && [ "$answer" != "$option2" ]
		then
			echo "Enter one of the two choices"
		else
			if [ -z "$answer" ]
			then
				answer=$default
			fi
			break
		fi
	done
	RET=$answer
	
}
