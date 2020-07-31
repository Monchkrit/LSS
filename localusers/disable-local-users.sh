#!/bin/bash
#
# This is a script to drop users.

# This function is output to the screen to demonstrate usage.
usage() {
	echo "Usage: sudo ${0} [-vrda] [USER1] [USER2] [...]"
	echo "	-v Verbose mode on."
	echo "	-r Remove the home folder for the user."
	echo "	-d Deletes the account instead of the default disable."
	echo "	-a Creates an archive of the user home directory."
}

# This log function is to help with debugging.
log() {
	local MESSAGE="${@}"
	if [[ "${VERBOSE}" = 'true' ]]
	then
		echo "${MESSAGE}"
	fi
}


# Check to make sure the user is root or running sudo.
if [[ "${UID}" -ne 0 ]]
then
	echo "You need to be root or run with sudo privileges."
	exit 1
fi

# See if there are any operators on the script. If not, then just disable the account and exit.
while getopts vdra OPTION
do
	case ${OPTION} in
	
		v)
			VERBOSE='true'
			log 'Verbose mode on.'
			;;
		a)
			ARCHIVE='true'
			;;
		r)
			REMOVE='true'
			;;
		d)
			DELETE='true'
			;;
		?)
			usage
			;;
	esac
done

# Remove the options and see which arguments are left.
shift "$(( OPTIND - 1 ))"

# Make sure there are some users to delete
if [[ "${#}" -eq 0 ]]
then
	usage
fi


# Loop through the positional parameters and handle the accounts
for USER_NAME in "${@}"
do
	ID=$(id -u ${USER_NAME})
	if [[ "${ID}" -lt 1000 ]]
	then
		echo "Are you crazy? You could delete a system account."
		exit 1
	fi

	if [[ "${ARCHIVE}" = 'true' ]]
	then
		echo "Archive is: ${ARCHIVE}"
		tar --create --file "${USER_NAME}Backup.tar" "/home/${USER_NAME}" &>/dev/null
	fi

	if [ "${DELETE}" = 'true' ]
	then
		echo "I will remove ${USER_NAME}"
		userdel "${USER_NAME}"
	else
		echo "The account ${USER_NAME} is expired."
		chage -E 0 ${USER_NAME}
	fi
	
	if [[ "${REMOVE}" = 'true' ]]
	then
		echo "I will remove the home folder for remove ${USER_NAME}"
		rm -rf "/home/${USER_NAME}"
	fi
done
exit 0
