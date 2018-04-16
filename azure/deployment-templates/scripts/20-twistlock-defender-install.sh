#!/usr/bin/env bash
set -e

IMAGE_ID=`docker ps -a | grep "twistlock/private:defender" | cut -d " " -f 1`

if [ $INSTALL_TWISTLOCK = "True" ]; then
    if [[ $IMAGE_ID ]]; then
        echo "Twistlock Defender already installed!"
    else
        echo "Installing Twistlock Defender"
        curl -sSL -k --header "authorization: Bearer $TL_BEARER" https://$TL_HOST:$TL_PORT/api/v1/scripts/defender.sh | sudo bash -s -- -c "$TL_HOST" -d "TCP"  -p "" -n ""
    fi
else
    if [[ $IMAGE_ID ]]; then
        echo "Twistlock Defender removed"
        docker stop $IMAGE_ID
        docker rm $IMAGE_ID
    else
        echo "Twistlock Defender installed, moving on!"
    fi
fi
