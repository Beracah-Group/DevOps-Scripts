#!/bin/sh
set -e
umask 077

IMAGE=$1
if [ "$IMAGE" = "" ]; then
    IMAGE=rancher/enterprise:v$RANCHER_VERSION
fi

echo Creating /rancher-ha-start.sh
cat > /rancher-ha-start.sh << "EOF"
#!/bin/sh
set -e

IMAGE=$1
if [ "$IMAGE" = "" ]; then
    echo Usage: $0 DOCKER_IMAGE
    exit 1
fi

`docker rm -fv rancher-ha >/dev/null 2>&1 || true`
ID=`docker run -d --restart=unless-stopped -p 8080:8080 -p 9345:9345 --name rancher-ha $IMAGE --db-host $DB_HOST --db-port $DB_PORT --db-user $DB_USER --db-pass "$DB_PASS" --db-name $DB_NAME --advertise-address $(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)`

echo Started container rancher-ha $ID
echo Run the below to see the logs
echo
echo docker logs -f rancher-ha
EOF

chmod +x /rancher-ha-start.sh

echo Running: /rancher-ha-start.sh $IMAGE

exec /rancher-ha-start.sh $IMAGE

sleep 5

# Loop every 15 seconds until rancher-ha container is running

until [ `docker inspect --format='{{.State.Status}}' rancher-ha` == 'running' ]
do
  sleep 5
  echo "Trying to start rancher-ha container again"
  exec /rancher-ha-start.sh $IMAGE
done

echo To re-run please execute: /rancher-ha-start.sh $IMAGE
exec /rancher-ha-start.sh $IMAGE