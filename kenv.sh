#!/bin/bash

DB_NAME=local

while getopts "sl" opt; do
	case $opt in
	s) DB_NAME=shared ;;
	l) DB_NAME=local ;;
	*) echo "Unknown flag" ;;
	esac
done

function replace_line {
	ENV_PATH=$1
	KEY=$2
	NEW_VALUE=$3

	sed -i.bak "/^$KEY=/c\\
"$KEY=$NEW_VALUE"
	" "$ENV_PATH"
}

source .env

DF_DB_URL=$DF_LOCAL_DB_URL
CM_DB_URL=$CM_LOCAL_DB_URL

SC_DB_HOST=$SC_LOCAL_DB_HOST
SC_DB_NAME=$SC_LOCAL_DB_NAME
SC_DB_PASSWORD=$SC_LOCAL_DB_PASSWORD
SC_DB_USER=$SC_LOCAL_DB_USER

if [[ $DB_NAME == "shared" ]]; then
	DF_DB_URL=$DF_SHARED_DB_URL
	CM_DB_URL=$CM_SHARED_DB_URL

	SC_DB_HOST=$SC_SHARED_DB_USER
	SC_DB_NAME=$SC_SHARED_DB_NAME
	SC_DB_PASSWORD=$SC_SHARED_DB_PASSWORD
	SC_DB_USER=$SC_SHARED_DB_USER
fi

SC_PATH=~/dev/signals-core/.env
DF_PATH=~/dev/data-fetch/.env
CM_PATH=~/dev/channel-manager/.env

replace_line $SC_PATH DB_HOST $SC_DB_HOST
replace_line $SC_PATH DB_NAME $SC_DB_NAME
replace_line $SC_PATH DB_PASSWORD $SC_DB_PASSWORD
replace_line $SC_PATH DB_USER $SC_DB_USER
replace_line $CM_PATH DB_URL $CM_DB_URL
replace_line $DF_PATH DB_URL $DF_DB_URL

echo "now using $DB_NAME db"
