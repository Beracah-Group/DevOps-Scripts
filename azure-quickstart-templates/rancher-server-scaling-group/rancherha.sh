#!/bin/sh
set -e
umask 077

IMAGE=$1
if [ "$IMAGE" = "" ]; then
    IMAGE=rancher/server:v2.0.0-alpha10
fi

mkdir -p /var/lib/rancher/etc/server
mkdir -p /var/lib/rancher/etc/ssl
mkdir -p /var/lib/rancher/bin

echo Creating /var/lib/rancher/etc/server/encryption.key
if [ -e /var/lib/rancher/etc/server/encryption.key ]; then
    mv /var/lib/rancher/etc/server/encryption.key /var/lib/rancher/etc/server/encryption.key.`date '+%s'`
fi
cat > /var/lib/rancher/etc/server/encryption.key << EOF
$ENCRYPTION_KEY
EOF


echo Creating /var/lib/rancher/bin/rancher-ha-start.sh
cat > /var/lib/rancher/bin/rancher-ha-start.sh << "EOF"
#!/bin/sh
set -e

IMAGE=$1
if [ "$IMAGE" = "" ]; then
    echo Usage: $0 DOCKER_IMAGE
    exit 1
fi

docker rm -fv rancher-ha >/dev/null 2>&1 || true
ID=`docker run --restart=unless-stopped -p 8080:8080 -p 9345:9345 -d --name rancher-ha $IMAGE --db-host $DB_HOST --db-port $DB_PORT --db-user $DB_USER --db-pass "$DB_PASS" --db-name $DB_NAME --advertise-address $(hostname -i)`

echo Started container rancher-ha $ID
echo Run the below to see the logs
echo
echo docker logs -f rancher-ha
EOF

chmod +x /var/lib/rancher/bin/rancher-ha-start.sh

echo Running: /var/lib/rancher/bin/rancher-ha-start.sh $IMAGE

`/var/lib/rancher/bin/rancher-ha-start.sh $IMAGE`

sleep 5

# Loop every 15 seconds until rancher-ha container is running

until [ `docker inspect --format='{{.State.Status}}' rancher-ha` == 'running' ]
do
  sleep 5
  echo "Trying to start rancher-ha container again"
  `/var/lib/rancher/bin/rancher-ha-start.sh $IMAGE`
done

echo To re-run please execute: /var/lib/rancher/bin/rancher-ha-start.sh $IMAGE
exec /var/lib/rancher/bin/rancher-ha-start.sh $IMAGE