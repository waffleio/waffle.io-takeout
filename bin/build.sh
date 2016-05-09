#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/colors.sh

trap "echo -e \"\n\n${red}Exiting...${reset}\n\"; exit;" SIGINT SIGTERM

hash docker 2>/dev/null || { echo -e >&2 "${red}I require docker but it's not installed.  Aborting.${reset}"; exit 1; }

if [ $WAFFLE_QUAYIO_USERNAME ] && [ $WAFFLE_QUAYIO_PASSWORD ] && [ $WAFFLE_QUAYIO_EMAIL ]
then
  echo -e "\n${blue}Logging in to quay.io${reset}"
  docker login -u $WAFFLE_QUAYIO_USERNAME -p $WAFFLE_QUAYIO_PASSWORD -e $WAFFLE_QUAYIO_EMAIL quay.io || { exit 1; }
else
  echo -e "\n${blue}Please login to quay.io${reset}"
  docker login quay.io || { exit 1; }
fi

mkdir -p waffleio-takeout/{bin,images,etc}
mkdir -p waffleio-takeout/etc/{init.d,waffle/nginx/vhost.d}

echo -e "\nPulling images from quay.io...${grey}"
docker pull quay.io/waffleio/hedwig
docker pull quay.io/waffleio/poxa
docker pull quay.io/waffleio/waffle.io-admin
docker pull quay.io/waffleio/waffle.io-api
docker pull quay.io/waffleio/waffle.io-app
docker pull quay.io/waffleio/waffle.io-hooks
docker pull quay.io/waffleio/waffle.io-migrations
docker pull quay.io/waffleio/takeout-nginx
echo -e "${reset}"

echo -e "Packaging images into tarballs"
echo -e "${grey}  Packaging hedwig...${reset}"
docker save --output="waffleio-takeout/images/hedwig.tar" quay.io/waffleio/hedwig
echo -e "${grey}  Packaging poxa...${reset}"
docker save --output="waffleio-takeout/images/poxa.tar" quay.io/waffleio/poxa
echo -e "${grey}  Packaging waffle.io-api...${reset}"
docker save --output="waffleio-takeout/images/waffle.io-api.tar" quay.io/waffleio/waffle.io-api
echo -e "${grey}  Packaging waffle.io-app...${reset}"
docker save --output="waffleio-takeout/images/waffle.io-app.tar" quay.io/waffleio/waffle.io-app
echo -e "${grey}  Packaging waffle.io-admin...${reset}"
docker save --output="waffleio-takeout/images/waffle.io-admin.tar" quay.io/waffleio/waffle.io-admin
echo -e "${grey}  Packaging waffle.io-hooks...${reset}"
docker save --output="waffleio-takeout/images/waffle.io-hooks.tar" quay.io/waffleio/waffle.io-hooks
echo -e "${grey}  Packaging waffle.io-migrations...${reset}"
docker save --output="waffleio-takeout/images/waffle.io-migrations.tar" quay.io/waffleio/waffle.io-migrations
echo -e "${grey}  Packaging takeout-nginx...${reset}"
docker save --output="waffleio-takeout/images/takeout-nginx.tar" quay.io/waffleio/takeout-nginx

cp bin/install.sh waffleio-takeout/
cp bin/colors.sh waffleio-takeout/bin
cp bin/make-root-ca-and-certificates.sh waffleio-takeout/bin
cp -r ./etc waffleio-takeout/

echo -e "\nZipping files together${grey}"
timestamp="$(date +"%Y-%m-%d-%H:%M:%S")"
if [ $1 ]
then
  suffix="-${1}"
else
  suffix=""
fi
zip -r waffleio-takeout-${timestamp}${suffix}.zip waffleio-takeout
rm -rf waffleio-takeout/
echo -e "${reset}"

echo 'Finished'
