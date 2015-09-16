#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/bin/colors.sh

trap "echo -e \"\n\n${red}Exiting...${reset}\n\"; exit;" SIGINT SIGTERM

#!/bin/bash
if (( EUID != 0 )); then
    echo -e "\n${red}We need root access in order to set up init.d scripts and save off environment configuration in /etc/waffle.\n\nPlease run ./install.sh as root.${reset}\n" 1>&2
    exit 1
fi

hash docker 2>/dev/null || { echo -e >&2 "${red}I require docker but it's not installed.  Aborting.${reset}"; exit 1; }

echo -e "\nWelcome to Waffle.io Takeout!"
echo -e "\nWe need to get some information about your environment to get started."

if [ -f "/etc/waffle/environment.list" ];
then
  source "/etc/waffle/environment.list"
fi
envFile='./etc/waffle/environment.list'
source $envFile

###############################################
# Setting up connecting environment variables #
###############################################
echo -en "\n${blue}What is the hostname for this machine that you want to use to talk to your Waffle.io Takeout?: ($HOST_NAME)\n> ${reset}"
while [ -z "$hostName" ]; do
  echo -en $"${grey}Please enter the hostname of the host machine (blank to keep it the same):\n>${reset}"
  read hostName
  hostName=${hostName:-$HOST_NAME}
done
sed -n '/HOST_NAME/!p' $envFile > tmp.list && mv tmp.list $envFile
echo HOST_NAME=$hostName >> $envFile

sed -n '/WAFFLE_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WAFFLE_BASE_URL="https://${hostName}" >> $envFile
sed -n '/WAFFLE_API_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WAFFLE_API_BASE_URL="https://${hostName}/api" >> $envFile
sed -n '/WAFFLE_HOOKS_SERVICE_URI/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WAFFLE_HOOKS_SERVICE_URI="https://${hostName}/hooks" >> $envFile
sed -n '/RALLY_INTEGRATION_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
echo RALLY_INTEGRATION_BASE_URL="https://${hostName}/integrations/rally" >> $envFile
sed -n '/POXA_HOST/!p' $envFile > tmp.list && mv tmp.list $envFile
echo POXA_HOST="${hostName}" >> $envFile
sed -n '/POXA_PORT/!p' $envFile > tmp.list && mv tmp.list $envFile
echo POXA_PORT=443 >> $envFile

echo -e "\n"
echo "#######################"
echo "# Proxy configuration #"
echo "#######################"
echo -en "\n${blue}Waffle supports integrations with GitHub:Enterprise, GitHub.com, and Rally (rally1.rallydev.com). Will your Takeout installation need to talk through a proxy to connect to any of these integrations, if enabled? (Y/n)\n${grey}>${reset}"

read needsProxy
if [[ $needsProxy =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo -e "For more details on how to configure your proxy for our integrations, see https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#proxy-configuration."

  if [ $HTTPS_PROXY ]
  then
    echo -e "\n${blue}What is your proxy url? Please include the protocol and port. (${HTTPS_PROXY})${reset}"
  else
    echo -e "\n${blue}What is your proxy url? Please include the protocol and port.${reset}"
  fi

  while [ -z "$proxyUrl" ]; do
    echo -en $"${grey}Please enter the proxy url (blank to keep it the same):\n>${reset}"
    read proxyUrl
    proxyUrl=${proxyUrl:-$HTTPS_PROXY}
  done

  sed -n '/HTTPS_PROXY/!p' $envFile > tmp.list && mv tmp.list $envFile
  sed -n '/HTTP_PROXY/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo HTTPS_PROXY=$proxyUrl >> $envFile
  echo HTTP_PROXY=$proxyUrl >> $envFile

  echo -e "\nThe proxy will be used for all connections, unless specific domains are excluded. Often, requests to GitHub.com must be proxied, but requests to GitHub Enterprise do not. Please enter any domains, comma-separated, that do not need to be proxied (e.g., github.yourcompany.com)."
  if [ $NO_PROXY ]
  then
    echo -e "\n${blue}Enter a list of domains to exclude from the proxy. (${NO_PROXY})${reset}"
  else
    echo -e "\n${blue}Enter a list of domains to exclude from the proxy.${reset}"
  fi

  while [ -z "$noProxyDomains" ]; do
    echo -en $"${grey}Enter a list of domains to exclude from the proxy, comma-separated (blank to keep it the same):\n>${reset}"
    read noProxyDomains
    noProxyDomains=${noProxyDomains:-$NO_PROXY}
  done

  sed -n '/NO_PROXY/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo NO_PROXY=$noProxyDomains >> $envFile

else
  echo "Skipping proxy configuration. You may rerun this script if you wish to configure it later."
fi

echo -e "\n"
echo "#############################################"
echo "# GitHub:Enterprise OAuth Application Setup #"
echo "#############################################"
echo -e "Many Waffle.io Takeout users also use GitHub:Enterprise. In order for Waffle.io Takeout to connect to a GitHub:Enterprise install, we need to create an OAuth application. This section of the setup will guide you through how to do that."
echo -en "\n${blue}Do you have a GitHub:Enterprise installation that you would like to be your primary GitHub instance for Waffle.io Takeout? (Y/n)\n${grey}>${reset}"
sed -n '/IS_GHE_PRIMARY/!p' $envFile > tmp.list && mv tmp.list $envFile
read isGHEPrimary
if [[ $isGHEPrimary =~ ^([yY][eE][sS]|[yY])$ ]]
then
  if [ $GHE_BASE_URL ]
  then
    echo -e "\n${blue}What is the url of your GitHub:Enterprise install? Please include the protocol. (${GHE_BASE_URL})${reset}"
  else
    echo -e "\n${blue}What is the url of your GitHub:Enterprise install? Please include the protocol.${reset}"
  fi

  while [ -z "$primaryGitHubBaseUrl" ]; do
    echo -en $"${grey}Please enter the url to your GitHub:Enterprise install (blank to keep it the same):\n>${reset}"
    read primaryGitHubBaseUrl
    primaryGitHubBaseUrl=${primaryGitHubBaseUrl:-$GHE_BASE_URL}
  done

  sed -n '/GHE_BASE_URL/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo GHE_BASE_URL=$primaryGitHubBaseUrl >> $envFile

  echo IS_GHE_PRIMARY=true >> $envFile

  echo -e "\nWe need to configure an OAuth Application for Waffle.io Takeout. Please go to ${primaryGitHubBaseUrl%/}/settings/applications and register an application with the following configuration:"
  echo -e "     Application name:           Waffle.io Takeout"
  echo -e "     Homepage URL:               https://${hostName}"
  echo -e "     Application description:    Automate your workflow."
  echo -e "     Authorization callback URL: https://${hostName}"
  echo -e "     Application Logo:           https://brandfolder.com/waffleio/share/1FBJUQk"
echo -e "After registering your application, you will be given a Client ID and Client Secret."

  # Client ID
  if [ $GHE_CLIENT_ID ]
  then
    echo -e "\n${blue}What is your GitHub:Enterprise OAuth Client ID? (${GHE_CLIENT_ID})${reset}"
  else
    echo -e "\n${blue}What is your GitHub:Enterprise OAuth Client ID?${reset}"
  fi

  while [ -z "$gheClientId" ]; do
    echo -en $"${grey}Please enter your GitHub:Enterprise OAuth Client ID (blank to keep it the same):\n>${reset}"
    read gheClientId
    gheClientId=${gheClientId:-$GHE_CLIENT_ID}
  done

  sed -n '/GHE_CLIENT_ID/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo GHE_CLIENT_ID=$gheClientId >> $envFile

  # Client Secret
  if [ $GHE_CLIENT_SECRET ]
  then
    echo -e "${blue}What is your GitHub:Enterprise OAuth Client Secret? (${GHE_CLIENT_SECRET})${reset}"
  else
    echo -e "${blue}What is your GitHub:Enterprise OAuth Client Secret?${reset}"
  fi

  while [ -z "$gheClientSecret" ]; do
    echo -en $"${grey}Please enter your GitHub:Enterprise OAuth Client Secret (blank to keep it the same):\n>${reset}"
    read gheClientSecret
    gheClientSecret=${gheClientSecret:-$GHE_CLIENT_SECRET}
  done

  sed -n '/GHE_CLIENT_SECRET/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo GHE_CLIENT_SECRET=$gheClientSecret >> $envFile
else
  echo "Skipping GitHub:Enterprise OAuth Application setup. You may rerun this script if you wish to configure it later."
fi

echo -e "\n"
echo "######################################"
echo "# GitHub.com OAuth Application Setup #"
echo "######################################"
echo "Many Waffle.io Takeout users want to access GitHub.com from their Takeout install. In order for Waffle.io Takeout to connect to GitHub.com, we need to create an OAuth application. This section of the setup will guide you through how to do that."
echo -en "\n${blue}Do you want your Waffle.io Takeout to connect to GitHub.com? (Y/n)\n${grey}>${reset}"
read wantsGitHubSaas
if [[ $wantsGitHubSaas =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo -e "\nWe need to configure an OAuth Application for Waffle.io Takeout. Please go to https://github.com/settings/applications and register an application with the following configuration:"
  echo -e "     Application name:           Waffle.io Takeout"
  echo -e "     Homepage URL:               https://${hostName}"
  echo -e "     Application description:    Automate your workflow."
  echo -e "     Authorization callback URL: https://${hostName}"
  echo -e "     Application Logo:           https://brandfolder.com/waffleio/share/1FBJUQk"
  echo -e "After registering your application, you will be given a Client ID and Client Secret."

  # Client ID
  if [ $APPLICATION_CLIENT_ID ]
  then
    echo -e "\n${blue}What is your GitHub.com OAuth Client ID? (${APPLICATION_CLIENT_ID})${reset}"
  else
    echo -e "\n${blue}What is your GitHub.com OAuth Client ID?${reset}"
  fi

  while [ -z "$githubClientId" ]; do
    echo -en $"${grey}Please enter your GitHub.com OAuth Client ID (blank to keep it the same):\n>${reset}"
    read githubClientId
    githubClientId=${githubClientId:-$APPLICATION_CLIENT_ID}
  done

  sed -n '/APPLICATION_CLIENT_ID/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo APPLICATION_CLIENT_ID=$githubClientId >> $envFile

  # Client Secret
  if [ $APPLICATION_CLIENT_SECRET ]
  then
    echo -e "${blue}What is your GitHub.com OAuth Client Secret? (${APPLICATION_CLIENT_SECRET})${reset}"
  else
    echo -e "${blue}What is your GitHub.com OAuth Client Secret?${reset}"
  fi

  while [ -z "$githubClientSecret" ]; do
    echo -en $"${grey}Please enter your GitHub.com OAuth Client Secret (blank to keep it the same):\n>${reset}"
    read githubClientSecret
    githubClientSecret=${githubClientSecret:-$APPLICATION_CLIENT_SECRET}
  done

  sed -n '/APPLICATION_CLIENT_SECRET/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo APPLICATION_CLIENT_SECRET=$githubClientSecret >> $envFile
else
  sed -n '/APPLICATION_CLIENT_ID/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo APPLICATION_CLIENT_ID=not-a-real-client-id >> $envFile
  sed -n '/APPLICATION_CLIENT_SECRET/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo APPLICATION_CLIENT_SECRET=not-a-real-client-secret >> $envFile
  echo "Skipping GitHub.com OAuth Application setup. You may rerun this script if you wish to configure it later."
fi

echo -e "\n"
echo "#################################"
echo "# Rally OAuth Application Setup #"
echo "#################################"
echo -e "Waffle.io Takeout offers a Rally integration that enables your devs to work in Waffle while still giving all the business folk the data they need in Rally. In order for this to work, Waffle.io Takeout needs an OAuth Application in Rally. This section of the setup will walk you through how to do that."
echo -en "\n${blue}Do you have a Rally Subscription? (Y/n)\n${grey}>${reset}"
read hasRally
if [[ $hasRally =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo -e "\nPlease go to https://rally1.rallydev.com/login/accounts/index.html#/clients and register an application with the following configuration:"
  echo -e "     Application name:           Waffle.io Takeout"
  echo -e "     Homepage URL:               https://${hostName}"
  echo -e "     Authorization callback URL: https://${hostName}/rally-callback"
  echo -e "     Application Logo:           https://brandfolder.com/waffleio/share/1FBJUQk"
  echo -e "After registering your application, you will be given a Client ID and Client Secret."

  # Client ID
  if [ $RALLY_CLIENT_ID ]
  then
    echo -e "\n${blue}What is your Rally OAuth Client ID? (${RALLY_CLIENT_ID})${reset}"
  else
    echo -e "\n${blue}What is your Rally OAuth Client ID?${reset}"
  fi

  while [ -z "$rallyClientId" ]; do
    echo -en $"${grey}Please enter your Rally OAuth Client ID (blank to keep it the same):\n>${reset}"
    read rallyClientId
    rallyClientId=${rallyClientId:-$RALLY_CLIENT_ID}
  done

  sed -n '/RALLY_CLIENT_ID/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo RALLY_CLIENT_ID=$rallyClientId >> $envFile

  # Client Secret
  if [ $RALLY_CLIENT_SECRET ]
  then
    echo -e "${blue}What is your Rally OAuth Client Secret? (${RALLY_CLIENT_SECRET})${reset}"
  else
    echo -e "${blue}What is your Rally OAuth Client Secret?${reset}"
  fi

  while [ -z "$rallyClientSecret" ]; do
    echo -en $"${grey}Please enter your Rally OAuth Client Secret (blank to keep it the same):\n>${reset}"
    read rallyClientSecret
    rallyClientSecret=${rallyClientSecret:-$RALLY_CLIENT_SECRET}
  done

  sed -n '/RALLY_CLIENT_SECRET/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo RALLY_CLIENT_SECRET=$rallyClientSecret >> $envFile
else
  sed -n '/RALLY_CLIENT_ID/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo RALLY_CLIENT_ID=not-a-real-client-id >> $envFile
  sed -n '/RALLY_CLIENT_SECRET/!p' $envFile > tmp.list && mv tmp.list $envFile
  echo RALLY_CLIENT_SECRET=not-a-real-client-secret >> $envFile
  echo "Skipping Rally OAuth Application setup. You may rerun this script if you wish to configure it later."
fi

echo -e "\n"
echo "#####################"
echo "# Environment Setup #"
echo "#####################"
echo "Just a few more questions about your environment. NOTE: we currently require you to run your own instance of MongoDB."

# MONGOLAB_URI
if [ $MONGOLAB_URI ]
then
  echo -e "\n${blue}What is the connect string for your MongoDB instance? (${MONGOLAB_URI})${reset}"
else
  echo -e "\n${blue}What is the connect string for your MongoDB instance?${reset}"
fi

while [ -z "$mongoDbConnectString" ]; do
  echo -en $"${grey}Please enter a MongoDB connect string (blank to keep it the same):\n>${reset}"
  read mongoDbConnectString
  mongoDbConnectString=${mongoDbConnectString:-$MONGOLAB_URI}
done

sed -n '/MONGOLAB_URI/!p' $envFile > tmp.list && mv tmp.list $envFile
echo MONGOLAB_URI=$mongoDbConnectString >> $envFile

# WAFFLE_DB_ENCRYPTION_KEY
if [ -z "$WAFFLE_DB_ENCRYPTION_KEY" ];
then
  encryptionkey=$(openssl rand -base64 32)
  echo WAFFLE_DB_ENCRYPTION_KEY=$encryptionkey >> $envFile
fi

# WAFFLE_DB_SIGNING_KEY
if [ -z "$WAFFLE_DB_SIGNING_KEY" ];
then
  signingKey=$(openssl rand -base64 64 | tr -d '\n') # remove random newline in middle of key
  echo WAFFLE_DB_SIGNING_KEY=$signingKey >> $envFile
fi

# WAFFLE_SESSION_SECRET
if [ -z "$WAFFLE_SESSION_SECRET" ];
then
  sessionSecret=$(openssl rand -base64 32)
  echo WAFFLE_SESSION_SECRET=$sessionSecret >> $envFile
fi

# WEB_CONCURRENCY
if [ $WEB_CONCURRENCY ]
then
  echo -e "\n${blue}How many CPUs would you like to use? (${WEB_CONCURRENCY})${reset}"
else
  echo -e "\n${blue}How many CPUs would you like to use?${reset}"
fi

while [[ ! $webConcurrency || $webConcurrency = *[^0-9]* ]]; do
  echo -en $"${grey}Please enter in a number (blank to keep it the same):\n>${reset}"
  read webConcurrency
  webConcurrency=${webConcurrency:-$WEB_CONCURRENCY}
done

sed -n '/WEB_CONCURRENCY/!p' $envFile > tmp.list && mv tmp.list $envFile
echo WEB_CONCURRENCY=$webConcurrency >> $envFile

echo -e "\n\nGreat! That's all we need, we will have your Waffle.io Takeout ready shortly."

######################################################
# Store off environment configuration in /etc/waffle #
######################################################
echo -e "\n\nSaving environment configuration in /etc/waffle/"
sudo mkdir -p /etc/waffle
sudo cp $envFile /etc/waffle/environment.list

########################
# Setup init.d scripts #
########################
echo -e "Setting up init.d scripts"
sudo cp ./etc/init.d/* /etc/init.d
sudo chmod +x /etc/init.d/waffle
sudo chmod +x /etc/init.d/waffle-api
sudo chmod +x /etc/init.d/waffle-app
sudo chmod +x /etc/init.d/waffle-hedwig
sudo chmod +x /etc/init.d/waffle-hooks
sudo chmod +x /etc/init.d/waffle-poxa
sudo chmod +x /etc/init.d/waffle-rally-integration
sudo chmod +x /etc/init.d/waffle-nginx


#############################
# Creating SSL Certificates #
#############################
echo -e "Creating a self-signed certificate${grey}"
sudo mkdir -p /etc/waffle/{ca-certificates,nginx/certs}
(./bin/make-root-ca-and-certificates.sh \
  --hostname=$hostName \
  --ca-dir /etc/waffle/ca-certificates \
  --certificates-dir /etc/waffle/nginx/certs)
echo -en "${reset}"

#############################
# Load in the Docker images #
#############################
echo -e "\nLoading in the docker images, this might take a few minutes:"
echo -ne '[                           ] (0%)\r'
docker load --input images/hedwig.tar
echo -ne '[###                        ] (11%)\r'
docker load --input images/poxa.tar
echo -ne '[######                     ] (22%)\r'
docker load --input images/waffle.io-api.tar
echo -ne '[#########                  ] (33%)\r'
docker load --input images/waffle.io-app.tar
echo -ne '[############               ] (44%)\r'
docker load --input images/waffle.io-hooks.tar
echo -ne '[###############            ] (55%)\r'
docker load --input images/waffle.io-migrations.tar
echo -ne '[##################         ] (66%)\r'
docker load --input images/waffle.io-rally-integration.tar
echo -ne '[#####################      ] (77%)\r'
docker load --input images/takeout-nginx.tar
echo -e  '[###########################] (100%)\r'

##################
# Run migrations #
##################
echo -e "\nMigrating the database."
docker run --env-file /etc/waffle/environment.list quay.io/waffleio/waffle.io-migrations

########################
# Start the containers #
########################
echo "Starting the docker images."
service waffle start

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

Your Waffle.io Takeout is ready for pick up. You can pick it up at https://${hostName}.

${yellow}WARNING: We have stored your environment configuration in /etc/waffle/environment.list. We recommend you back this file up. If it is lost or damaged we may not be able to recover your application state.${reset}

Happy Waffle'ing!"
