#!/bin/bash

blue='\033[0;34m'
grey="\033[1;30m"
red='\033[0;31m'
yellow='\033[1;33'
reset='\033[0m'

hash docker 2>/dev/null || { echo -e >&2 "${red}I require docker but it's not installed.  Aborting.${reset}"; exit 1; }

envFile='waffleio-env.list'

source $envFile

###############################################
# Setting up connecting environment variables #
###############################################
if hash boot2docker 2>/dev/null && [ $(boot2docker status) = 'running' ]
then
  hostIp=$(boot2docker ip)
elif ifconfig | grep -q eth0
then
  echo '1'
  hostIp=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
elif ifconfig | grep -q en1
then
  echo '2'
  hostIp=$(ipconfig getifaddr en1)
fi

if [ -z "$hostIp" ];
then
  echo -e -n "\n${blue}What is the IP address of the host machine (the machine this script is running on)?${grey}\n>${reset}"
  read hostIp
fi

appPort=3001
hooksPort=3002
rallyIntegrationPort=3003
poxaPort=3004

sed -n '/WAFFLE_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WAFFLE_BASE_URL="${hostIp}:${appPort}" >> $envFile
sed -n '/WAFFLE_HOOKS_SERVICE_URI/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WAFFLE_HOOKS_SERVICE_URI="${hostIp}:${hooksPort}" >> $envFile
sed -n '/RALLY_INTEGRATION_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
echo RALLY_INTEGRATION_BASE_URL="${hostIp}:${rallyIntegrationPort}" >> $envFile
sed -n '/POXA_HOST/!p' $envFile > tmp.list && mv tmp.list $envFile
echo POXA_HOST="${hostIp}" >> $envFile
sed -n '/POXA_PORT/!p' $envFile > tmp.list && mv tmp.list $envFile
echo POXA_PORT="${poxaPort}" >> $envFile

###################
# WEB_CONCURRENCY #
###################
echo
if [ $WEB_CONCURRENCY ]
then
  echo -e "${blue}How many CPUs would you like to use? (${WEB_CONCURRENCY}):${reset}"
else
  echo -e "${blue}How many CPUs would you like to use?${reset}"
fi

while [[ ! $webConcurrency || $webConcurrency = *[^0-9]* ]]; do
  echo -e -n $"${grey}Please enter in a number (blank to keep it the same):\n>${reset}"
  read webConcurrency
  webConcurrency=${webConcurrency:-$WEB_CONCURRENCY}
done

sed -n '/WEB_CONCURRENCY/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WEB_CONCURRENCY=$webConcurrency >> $envFile

################
# MONGOLAB_URI #
################
echo
if [ $MONGOLAB_URI ]
then
  echo -e "${blue}What is the connect string for your MongoDB instance? (${MONGOLAB_URI}):${reset}"
else
  echo -e "${blue}What is the connect string for your MongoDB instance?${reset}"
fi

while [ -z "$mongoDbConnectString" ]; do
  echo -e -n $"${grey}Please enter a MongoDB connect string (blank to keep it the same):\n>${reset}"
  read mongoDbConnectString
  mongoDbConnectString=${mongoDbConnectString:-$MONGOLAB_URI}
done

sed -n '/MONGOLAB_URI/!p' $envFile > tmp.list && mv tmp.list $envFile
echo MONGOLAB_URI=$mongoDbConnectString >> $envFile

############################
# WAFFLE_DB_ENCRYPTION_KEY #
############################
if [ -z "$WAFFLE_DB_ENCRYPTION_KEY" ];
then
  encryptionkey=$(openssl rand -base64 32)
  echo WAFFLE_DB_ENCRYPTION_KEY=$encryptionkey >> $envFile
fi

#############################
# Load in the Docker images #
#############################
echo -e "\nLoading in the docker images, this might take a few minutes:"
echo -ne '[                              ] (0%)\r'
docker load --input hedwig.tar
echo -ne '[#####                         ] (17%)\r'
docker load --input poxa.tar
echo -ne '[##########                    ] (33%)\r'
docker load --input waffle.io-app.tar
echo -ne '[###############               ] (50%)\r'
docker load --input waffle.io-hooks.tar
echo -ne '[####################          ] (67%)\r'
docker load --input waffle.io-models.tar
echo -ne '[#########################     ] (83%)\r'
docker load --input waffle.io-rally-integration.tar
echo -e  '[##############################] (100%)\r'

##################
# Run migrations #
##################
echo -e "\nMigrating the database."
docker run --env-file ./waffleio-env.list quay.io/waffleio/waffle.io-models

########################
# Start the containers #
########################
echo "Starting the docker images."
hedwigCID=$(docker run --env-file ./waffleio-env.list -d quay.io/waffleio/hedwig)
poxaCID=$(docker run --env-file ./waffleio-env.list -d -p $poxaPort:8080 quay.io/waffleio/poxa)
rallyIntegrationCID=$(docker run --env-file ./waffleio-env.list -d -p $rallyIntegrationPort:3001 quay.io/waffleio/waffle.io-rally-integration)
hooksCID=$(docker run --env-file ./waffleio-env.list -d -p $hooksPort:3004 quay.io/waffleio/waffle.io-hooks)
appCID=$(docker run --env-file ./waffleio-env.list -d -p $appPort:3001 quay.io/waffleio/waffle.io-app)

echo -e "\n\n"
echo "                              NN                              "
echo "                             NNNNN                            "
echo "                           NNNNNNNNN                          "
echo "                          NNNN  NNNNN                         "
echo "                        NNNNN     NNNNN                       "
echo "                      NNNNN         NNNN                      "
echo "                     NNNNNNN       NNNNNNN                    "
echo "                    NNNN NNNNN   NNNNN NNNNN                  "
echo "                  NNNNN    NNNNNNNNN    NNNNN                 "
echo "                NNNNN       NNNNNNN       NNNNN               "
echo "               NNNNNN       NNNNNNN       NNNNNN              "
echo "             NNNNNNNNN     NNNNNNNNN    NNNNNNNNNN            "
echo "            NNNN   NNNNN NNNNN   NNNNN NNNNN   NNNNN          "
echo "          NNNNN      NNNNNNN       NNNNNNN      NNNNN         "
echo "         NNNN         NNNNN         NNNNN        NNNNNN       "
echo "       NNNNNNNN      NNNNNNNN     NNNNNNNN      NNNNNNNN      "
echo "      NNNN  NNNNN  NNNNN  NNNN   NNNN  NNNNN  NNNNN  NNNNN    "
echo "    NNNNN    NNNNNNNNN     NNNNNNNNN     NNNNNNNNN    NNNNN   "
echo "  NNNNN        NNNNN         NNNNN         NNNNN        NNNNN "
echo "   NNNNN      NNNNNNN       NNNNNNN       NNNNNNN      NNNNN  "
echo "    NNNNN    NNNNNNNNNN    NNNN NNNNN   NNNNN NNNN    NNNN    "
echo "      NNNNNNNNNN    NNNNNNNNNN   NNNNN NNNN    NNNNNNNNNN     "
echo "        NNNNNNN      NNNNNNN       NNNNNNN       NNNNNN       "
echo "         NNNNN        NNNNN         NNNNN        NNNNN        "
echo "           NNNN     NNNNNNNNN     NNNNNNNNN     NNNNN         "
echo "            NNNNN  NNNNN  NNNNN  NNNN   NNNN  NNNNN           "
echo "              NNNNNNNN      NNNNNNNN     NNNNNNNN             "
echo "               NNNNN         NNNNN         NNNNN              "
echo "                 NNNNN      NNNNNNN      NNNNN                "
echo "                   NNNN   NNNNN NNNNN   NNNNN                 "
echo "                    NNNNNNNNNN    NNNNNNNNN N                 "
echo "                     NNNNNNN       NNNNNNN  N                 "
echo "                       NNNNN       NNNNN    N                 "
echo "                         NNNN     NNNN      N                 "
echo "                          NNNNN NNNNNN      N                 "
echo "                            NNNNNNN  N      N                 "
echo "                             NNNNN   N      N                 "
echo "                               N     N      N                 "
echo "                                     N      N                 "
echo "                                     N     NNN                "
echo "                                     N    NNNNN               "
echo "                                     NN    NNN                "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                     NN                       "
echo "                                    NNNN                      "
echo "                                   NNNNNN                     "
echo "                                    NNNN                      "
echo -e "

Your Waffle.io Takeout is ready for pick up. You can find it at ${hostIp}:${appPort}.

${yellow}WARNING: We have stored your environment configuration in ./${envFile}. We recommend you back this file up. If it is lost or damaged we may not be able to recover your application state.${reset}

Happy Waffling!"
