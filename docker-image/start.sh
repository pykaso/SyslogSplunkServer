#!/bin/bash

if [[ -z "${SPLUNK_PASSWD}" ]]; then
	echo "Stopping the server. No Splunk password environment variable with name 'SPLUNK_PASSWD' provided."
	exit
else
  SPLUNK_PASSWD="${SPLUNK_PASSWD}"
fi

cd /opt/splunkforwarder/bin
 
echo "Starting splunk daemon"
./splunk start --answer-yes --no-prompt --accept-license --seed-passwd $SPLUNK_PASSWD
 
echo "Install universal forwarder credentials"
./splunk install app /install/splunkclouduf.spl -auth admin:$SPLUNK_PASSWD

echo "Add Splunk monitor to mobile syslog output dir."
mkdir -p /var/log/splunk/
./splunk add monitor /var/log/splunk/
 
echo "Starting syslog-ng server"
/usr/sbin/syslog-ng -F --no-caps "$@"
