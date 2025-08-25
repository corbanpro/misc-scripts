#!/bin/bash

DB_ENV=local

while getopts "sl" opt; do
	case $opt in
	s) DB_ENV=shared ;;
	l) DB_ENV=local ;;
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

source ~/.scripts/.env

DF_DB_URL=$DF_LOCAL_DB_URL
CM_DB_URL=$CM_LOCAL_DB_URL

SC_DB_HOST=$SC_LOCAL_DB_HOST
SC_DB_NAME=$SC_LOCAL_DB_NAME
SC_DB_PASSWORD=$SC_LOCAL_DB_PASSWORD
SC_DB_USER=$SC_LOCAL_DB_USER

NV_DB_HOST=$NV_LOCAL_DB_HOST
NV_DB_NAME=$NV_LOCAL_DB_NAME
NV_DB_PASSWORD=$NV_LOCAL_DB_PASSWORD
NV_DB_USER=$NV_LOCAL_DB_USER

if [[ $DB_ENV == "shared" ]]; then
	DF_DB_URL=$DF_SHARED_DB_URL
	CM_DB_URL=$CM_SHARED_DB_URL

	SC_DB_HOST=$SC_SHARED_DB_HOST
	SC_DB_NAME=$SC_SHARED_DB_NAME
	SC_DB_PASSWORD=$SC_SHARED_DB_PASSWORD
	SC_DB_USER=$SC_SHARED_DB_USER

	NV_DB_HOST=$NV_SHARED_DB_HOST
	NV_DB_NAME=$NV_SHARED_DB_NAME
	NV_DB_PASSWORD=$NV_SHARED_DB_PASSWORD
	NV_DB_USER=$NV_SHARED_DB_USER
fi

SC_PATH=~/dev/signals-core/.env
DF_PATH=~/dev/data-fetch/.env
CM_PATH=~/dev/channel-manager/.env
NV_PATH=~/dev/signals-nerve/.env

replace_line $SC_PATH "DB_HOST" $SC_DB_HOST
replace_line $SC_PATH "DB_NAME" $SC_DB_NAME
replace_line $SC_PATH "DB_PASSWORD" $SC_DB_PASSWORD
replace_line $SC_PATH "DB_USER" $SC_DB_USER

replace_line $NV_PATH "DB_HOST" $NV_DB_HOST
replace_line $NV_PATH "DB_NAME" $NV_DB_NAME
replace_line $NV_PATH "DB_PASSWORD" $NV_DB_PASSWORD
replace_line $NV_PATH "DB_USER" $NV_DB_USER

replace_line $CM_PATH "DB_URL" $CM_DB_URL

replace_line $DF_PATH "DB_URL" $DF_DB_URL

echo "now using $DB_ENV db"
