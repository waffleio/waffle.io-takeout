# waffle.io-takeout
Scripts to package and install Waffle.io Takeout

## Building a shippable package
Running `./build.sh` will pull down all of the docker images, package them together in a zip file along with the install script, and upload the package to S3. You will need to have docker installed and be logged into quay.io. You can do that by running `docker login quay.io`.

## Installing Waffle.io Takeout locally
If you're a Waffle dev, clear out any waffle specific environment variables you set in your `.bash_profile` or `.zshrc` file and restart your terminal before continuing.

1. Retrieve the zipfile containing the latest version of takeout from S3.
2. Unzip the file, cd into it, and run `./install.sh`. You will be prompted for some some information about your install and then the script will take over from there.

## Installing Waffle.io Takeout on EC2

#### Hardware Requirements

 - We recommend at least 16GB of storage, and 3GB of memory.
 - Any linux distro with docker installed

#### Prerequisites

1. You need mongodb (v2.6) running somewhere. It's your responsibility to maintain your mongo installation.
  - You can install mongo on EC2 by following [these instructions](http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/).
2. If you plan to have your Waffle Takeout instance available through a hostname instead of an IP address (e.g., mapping the machine to waffle.io on your local network), you'll need to configure that during 

#### Installation

1. Follow [these instructions](https://docs.docker.com/installation/amazon/) to create an EC2 instance with docker installed.
  - minimum EC2 instance type: `t2.small`, with 16GB storage
  - to configure the root storage to be 16GB, instead of the default 8GB, go to the "Add Storage" tab when configuring your instance
 
2. Give your ssh user access to docker
  - Run `docker ps`. If this errors with: `Are you trying to connect to a TLS-enabled daemon without TLS?`, then run `sudo gpasswd -a ${USER} docker`.
3. [Configure a security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) to grant yourself ssh access to your EC2 instance.
4. Assign an [Elastic IP address](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to your instance, so your instance is always available by the same IP.
  - if you are planning to use a hostname, configure your network to use this IP address now. 
5. Download the latest Waffle Takeout from S3
6. Upload to EC2: `rsync -avz -e "ssh -i <your key pair>.pem" --progress /path/to/waffleio-takeout.zip ec2-user@<ec2 public ip>:`
7. ssh into your ec2 instance: `ssh -i <your key pair>.pem ec2-user@<ec2 public ip>`
8. `unzip waffleio-takeout.zip`
9. `cd waffleio-takeout`
10. `./install.sh`, and follow prompts.

## Setting up your dev environment
##### Install boot2docker:
``` bash
brew update
brew install caskroom/cask/brew-cask
brew cask install virtualbox
brew install boot2docker
boot2docker init
boot2docker up
export DOCKER_HOST=tcp://192.168.59.103:2376 # add to ~/.zshrc
```

## If something goes wrong during `./install.sh`

#### Clean out docker containers and images
1. stop any running containers.
  i. `docker ps` to see running containers
  ii. `docker stop <containerid>` to stop it
2. remove containers
  i. `docker rm <containerid>`
3. remove images
  ii. list images: `docker images`
  i. `docker rmi <imageid>


## If the installation went fine, but the app isn't starting

#### Look at the logs from the container
1. `docker ps` to see if any containers are running
2. If they are, find the id for the waffle.io-app container, run `docker logs <container id>`
