#!/usr/bin/env bash
set -e

# Write Docker config
cat <<EOF > /etc/rsyslog.d/49-syslog-to-elk.conf
#/etc/rsyslog.d/49-ship-syslog.conf
template(name="json-template"
  type="list") {
    constant(value="{")
      constant(value="\"@timestamp\":\"")     property(name="timereported" dateFormat="rfc3339")
      constant(value="\",\"message\":\"")     property(name="msg" format="json")
      constant(value="\",\"inputname\":\"")   property(name="inputname")
      constant(value="\",\"host\":\"")        property(name="hostname")
      constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
      constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
      constant(value="\",\"programname\":\"") property(name="programname")
      constant(value="\",\"procid\":\"")      property(name="procid")
    constant(value="\"}\n")
}

\$ActionQueueType LinkedList # use asynchronous processing
\$ActionQueueFileName srvrfwd # set file name, also enables disk mode
\$ActionResumeRetryCount -1 # infinite retries on insert failure
\$ActionQueueSaveOnShutdown on # save in-memory data if rsyslog shuts down

*.*                         @@localhost:9514;json-template
*.*                         @172.20.10.15
EOF

service rsyslog restart
