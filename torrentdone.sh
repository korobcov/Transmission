#!/bin/bash
# Torrent Done Script v0.9.16
#
# Tested on:
# Debian GNU/Linux 9.4 (stretch)
# transmission-daemon 2.92 (14714)
#
# Create logfile dir:
# mkdir /var/log/transmission && chown -R debian-transmission:debian-transmission /var/log/transmission

# INIT
LOGFILE="/var/log/transmission/torrentdone.log"
TRANSIP="127.0.0.1"
TRANSPORT="9091"
TR_LOGIN="user"
TR_PASSWORD="123456789"
TR_TORRENT_DIR="$TR_TORRENT_DIR/"
regex_ser="(LostFilm|TV|serial|Serial|novafilm|S[0-9]{2}|E[0-9]{2})"
regex_film="(\([0-9]+\)\.(mkv|avi|mp4))"
regex_3d="(\s(3D|3d)\s)"

# FUNCTIONS
function logging
{
	if [ -e $LOGFILE ]; then
		echo "`date '+%d.%m.%Y %H:%M:%S'`       $1" >> $LOGFILE
	else
		touch $LOGFILE
		echo "`date '+%d.%m.%Y %H:%M:%S'`       $1" >> $LOGFILE
	fi
}
function serialprocess
{
	# $1 - $TR_TORRENT_DIR + $TR_TORRENT_NAME
	# $2 - File or Directory (1 - File | 2 - Directory)

	logging "This File is Serial..."
	# Get Serial name
	local TR_TORRENT_NAME=`/usr/bin/basename "$1"` # example result: name.mkv
	logging "TR_TORRENT_NAME: $TR_TORRENT_NAME"
	# Get and Change Serial name
	local SERIALNAME=`echo $TR_TORRENT_NAME | /bin/grep -Eo '^(.*+).S[0-9].' | /bin/sed -r 's/(\.)/_/g' | /bin/sed -r 's/(_S[0-9].)//'`
	logging "SERIALNAME: $SERIALNAME"
	# Get Serial season
	local SEASON=`echo $TR_TORRENT_NAME | /bin/grep -Eo 'S[0-9].' | /bin/grep -Eo '[0-9].'`
	logging "SEASON: $SEASON"
	# Set Serial path
	local SERIALPATH="/mnt/data/media/serials/$SERIALNAME/Season_$SEASON/"
	logging "SERIALPATH: $SERIALPATH"
	# Check Serial path
	if ! [ -d $SERIALPATH ]; then
		logging "Path $SERIALPATH does not exist. Create the missing folders..."
		mkdir -m 777 -p $SERIALPATH
	fi
	# If File
	if [ $2 == 1 ]; then
		# Move Serial file
		logging "Move file $1 to folder $SERIALPATH"
		transmission-remote $TRANSIP:$TRANSPORT -n $TR_LOGIN:$TR_PASSWORD -t $TR_TORRENT_ID --move $SERIALPATH
	fi
	# If Dir
	if [ $2 == 2 ]; then
		# Copy Serial file
		logging "Copy file $1 to folder $SERIALPATH"
		cp $1 $SERIALPATH
	fi
	# Check result
	if [ -f "$SERIALPATH$TR_TORRENT_NAME" ]; then
		logging "File $TR_TORRENT_NAME successfully saved to folder $SERIALPATH"
	else
		logging "Error: File $TR_TORRENT_NAME NOT saved to folder $SERIALPATH$"
	fi
}
function filmprocess
{
	# $1 - $TR_TORRENT_DIR$TR_TORRENT_NAME
	# $2 - File or Directory (1 - File | 2 - Directory)
	# $3 - 3D or 2D (2 - 3D | 1 - 2D)

	logging "This File is Film..."
	# Get Film name
	local TR_TORRENT_NAME=`/usr/bin/basename "$1"` # example result: name.mkv
	logging "TR_TORRENT_NAME: $TR_TORRENT_NAME"
	# Get YEAR
	local YEAR=`echo $TR_TORRENT_NAME | /bin/grep -Eo '\([0-9]+\)' | /bin/sed -r 's/(\(|\))//g'`
	logging "YEAR: $YEAR"
	# Set Film path
	if [ $3 == 2 ]; then
		# 3D = 2
		local FILMPATH="/mnt/data/media/films/3D/$YEAR/"
	fi
	if [ $3 == 1 ]; then
		# 2D = 1
		local FILMPATH="/mnt/data/media/films/2D/$YEAR/"
	fi
	logging "FILMPATH: $FILMPATH"
	# Check Film path
	if ! [ -d $FILMPATH ]; then
		logging "Path $FILMPATH does not exist. Create the missing folders."
		mkdir -m 777 -p $FILMPATH
	fi
	# If File
	if [ $2 == 1 ]; then
		# Move Film file
		logging "Move file $1 to folder $FILMPATH"
		transmission-remote $TRANSIP:$TRANSPORT -n $TR_LOGIN:$TR_PASSWORD -t $TR_TORRENT_ID --move $FILMPATH
	fi
	# If Dir
	if [ $2 == 2 ]; then
		# Copy Film file
		logging "Copy file $1 to folder $FILMPATH"
		cp $1 $FILMPATH
	fi
	# Check result
	if [ -f "$FILMPATH$TR_TORRENT_NAME" ]; then
		logging "File $TR_TORRENT_NAME successfully saved to folder $FILMPATH"
	else
		logging "Error: File $TR_TORRENT_NAME NOT saved to folder $FILMPATH$"
	fi
}

# ACTION
# Start recording torrent information in a log file
logging "#========================# TORRENT ID: $TR_TORRENT_ID FINISH #========================#"
logging "VER:		Transmission - v$TR_APP_VERSION"
logging "DIR:		$TR_TORRENT_DIR"
logging "NAME:		$TR_TORRENT_NAME"
logging "DTIME:	$TR_TIME_LOCALTIME"
logging "HASH:		$TR_TORRENT_HASH"

# Check File or Directory
if [ -f "$TR_TORRENT_DIR$TR_TORRENT_NAME" ]; then
	# Is File
	logging "Start Torrent process - $TR_TORRENT_NAME"
	logging "Is File. Next..."
	FILE="$TR_TORRENT_DIR$TR_TORRENT_NAME"
	# Is serial?
	if [[ "${TR_TORRENT_NAME}" =~ $regex_ser ]]; then
		serialprocess $FILE 1
		exit 0;
	# Is Film?
	elif [[ "${TR_TORRENT_NAME}" =~ $regex_film ]]; then
		# Is Film 3D?
		if [[ "${TR_TORRENT_NAME}" =~ $regex_3d ]]; then
			# Is Film 3D
			filmprocess $FILE 1 2
			exit 0;
		else
			# Is film 2D
			filmprocess $FILE 1 1
			exit 0;
		fi
	# No Serial and no Film. Other file
	else
		logging "File(s) \"$TR_TORRENT_NAME\" not defined as TV show or movie"
		exit 0;
	fi
else
	# Is Directory
	logging "Start Torrent process - $TR_TORRENT_NAME"
	logging "Is Directory. Next..."
	for FILE in $TR_TORRENT_DIR$TR_TORRENT_NAME/*; do
		if  [[ $FILE != *.part ]]; then
			# FILE=FILE
			TR_TORRENT_NAME=`/usr/bin/basename "$FILE"`
			logging "###################### $TR_TORRENT_NAME #######################"
			# Is serial?
			if [[ "${TR_TORRENT_NAME}" =~ $regex_ser ]]; then
				serialprocess $FILE 2
			# Is Film?
			elif [[ "${TR_TORRENT_NAME}" =~ $regex_film ]]; then
				# Is Film 3D?
				if [[ "${TR_TORRENT_NAME}" =~ $regex_3d ]]; then
					filmprocess $FILE 2 2
				else
					filmprocess $FILE 2 1
				fi
			else
				logging "File(s) \"$TR_TORRENT_NAME\" not defined as TV show or movie"
			fi
		fi
	done
fi
exit 0;
