#!/bin/bash

blue='\033[0;34m'
red='\033[0;31m'
grey="\033[1;30m"
reset='\033[0m'

trap "echo -e \"\n\n${red}Exiting...${reset}\n\"; exit;" SIGINT SIGTERM

hash docker 2>/dev/null || { echo -e >&2 "${red}I require docker but it's not installed.  Aborting.${reset}"; exit 1; }

if [ ! $WAFFLE_AWS_ACCESS_KEY_ID ]
then
  echo -e "${red}You must supply an environment variable named $WAFFLE_AWS_ACCESS_KEY_ID set to your AWS access key.${reset}"
  exit 1
fi

if [ ! $WAFFLE_AWS_SECRET_ACCESS_KEY ]
then
  echo -e "${red}You must supply an environment variable named $WAFFLE_AWS_SECRET_ACCESS_KEY set to your AWS secret.${reset}"
  exit 1
fi

if [ $WAFFLE_QUAYIO_USERNAME ] && [ $WAFFLE_QUAYIO_PASSWORD ] && [ $WAFFLE_QUAYIO_EMAIL ]
then
  echo -e "\n${blue}Logging in to quay.io${reset}"
  docker login -u $WAFFLE_QUAYIO_USERNAME -p $WAFFLE_QUAYIO_PASSWORD -e $WAFFLE_QUAYIO_EMAIL quay.io
else
  echo -e "\n${blue}Please login to quay.io${reset}"
  docker login quay.io
fi

mkdir waffleio-takeout

echo -e "\nPulling images from quay.io...${grey}"
docker pull quay.io/waffleio/hedwig
docker pull quay.io/waffleio/poxa
docker pull quay.io/waffleio/waffle.io-app
docker pull quay.io/waffleio/waffle.io-hooks
docker pull quay.io/waffleio/waffle.io-migrations
docker pull quay.io/waffleio/waffle.io-rally-integration
docker pull quay.io/waffleio/waffle.io-admin
echo -e "${reset}"

echo -e "Packaging images into tarballs"
echo -e "${grey}  Packaging hedwig...${reset}"
docker save --output="waffleio-takeout/hedwig.tar" quay.io/waffleio/hedwig
echo -e "${grey}  Packaging poxa...${reset}"
docker save --output="waffleio-takeout/poxa.tar" quay.io/waffleio/poxa
echo -e "${grey}  Packaging waffle.io-app...${reset}"
docker save --output="waffleio-takeout/waffle.io-app.tar" quay.io/waffleio/waffle.io-app
echo -e "${grey}  Packaging waffle.io-hooks...${reset}"
docker save --output="waffleio-takeout/waffle.io-hooks.tar" quay.io/waffleio/waffle.io-hooks
echo -e "${grey}  Packaging waffle.io-migrations...${reset}"
docker save --output="waffleio-takeout/waffle.io-migrations.tar" quay.io/waffleio/waffle.io-migrations
echo -e "${grey}  Packaging waffle.io-rally-integration...${reset}"
docker save --output="waffleio-takeout/waffle.io-rally-integration.tar" quay.io/waffleio/waffle.io-rally-integration
echo -e "${grey}  Packaging waffle.io-admin...${reset}"
docker save --output="waffleio-takeout/waffle.io-admin.tar" quay.io/waffleio/waffle.io-admin

cp bin/install.sh waffleio-takeout/
cp *.list waffleio-takeout/
cp -r init.d waffleio-takeout/

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
