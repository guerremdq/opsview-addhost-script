#!/bin/bash
USERNAME_OPS="USERNAME"
PASSWORD_OPS="PASSWORD"
OPSVIEW_URL="http://opsview.foo.bar"
HOSTFILE=`tempfile`
HOSTNAME=`hostname --fqdn | tr '[:lower:]' '[:upper:]'`
IP_PUBLIC=`curl --silent ifconfig.me`
CURL=`which curl`
TOKEN=`$CURL --silent  -d '{"username":"'$USERNAME_OPS'","password":"'$PASSWORD_OPS'"}' -H "Content-Type: application/json" -H "Accept: application/json" $OPSVIEW_URL/rest/login | cut -d: -f2 | cut -d} -f1  | cut -d'"' -f2`

cat > $HOSTFILE << EOF
{
  "name": "$HOSTNAME",
  "ip": "$IP_PUBLIC",
  "hostgroup": {
    "name": "HOSTGROUP",
  },
  "hosttemplates": [
    {
      "name": "OS - Linux Base"
    }               ],
  "check_period": [
    {
    "name" : "24x7"
    }
	],
  "hostattributes": [
    {
	"arg2": null,
        "arg1": null,
        "arg4": null,
        "value": "/dev/vda1",
        "arg3": null,
        "name": "DISK"},
    {
        "arg2": null,
        "arg1": null,
        "arg4": null,
        "value": "/dev/vda2",
        "arg3": null,
        "name": "DISK"},
    {
        "arg2": null,
        "arg1": null,
        "arg4": null,
        "value": "eth0",
        "arg3": null,
        "name": "LAN_INTERFACE"},
	{
        "arg2": null,
        "arg1": null,
        "arg4": null,
        "value": "lo",
        "arg3": null,
        "name": "LAN_INTERFACE"}],
 "notification_period" : {
       "ref" : "/rest/config/timeperiod/1",
       "name" : "24x7"
 },
 "notification_options": "u,d,r",
 "notification_interval": "5",
 "icon" : 
        {
        "name" : "LOGO - centos" 
	},
 
 "check_command" : 
 {
     "ref" : "/rest/config/hostcheckcommand/17",
     "name" : "NRPE SSH"}
}

EOF

$CURL --silent -H "Accept: application/json" -H "X-Opsview-Username: $USERNAME_OPS" -H "X-Opsview-Token: $TOKEN" -H "Content-Type: application/json" -X PUT -d "@$HOSTFILE" $OPSVIEW_URL/rest/config/host

$CURL --silent -H "Accept: application/json" -H "X-Opsview-Username: $USERNAME_OPS" -H "X-Opsview-Token: $TOKEN" -H "Content-Type: application/json" -X POST $OPSVIEW_URL/rest/reload
