# waffle.io-takeout
Scripts to package and install Waffle.io Takeout

## Building a shippable package
Running `./build.sh` will pull down all of the docker images, package them together in a zip file along with the install script, and upload the package to S3. You will need to have docker installed and be logged into quay.io. You can do that by running `docker login quay.io`.

## Installing Waffle.io Takeout locally
If you're a Waffle dev, clear out any waffle specific environment variables you set in your `.bash_profile` or `.zshrc` file and restart your terminal before continuing.

1. Retrieve the zip file containing the latest version of takeout from S3.
2. Unzip the file, cd into it, and run `./install.sh`. You will be prompted for some some information about your install and then the script will take over from there.

## Installing Waffle.io Takeout on EC2

Prerequisites:
1. You need mongodb (v2.6) running somewhere. It's your responsibility to maintain your mongo installation.
- You can install mongo on EC2 by following [these instructions](http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/).

1. Follow [these instructions](https://docs.docker.com/installation/amazon/) to start an EC2 instance with docker installed.
  - minimum EC2 instance type: t2.small
  - configure the root storage to be 16GB, instead of the default 8GB ("Add Storage" tab) when configuring instance
  - (the takeout packaged file is 2GB, and unzipped is 5GB. Make sure your instance has disk space for this, plus ~3GB for runtime memory usage.)
2. Give your ssh user access to docker
  - Run `docker ps`. If this errors with: `Are you trying to connect to a TLS-enabled daemon without TLS?`, then run `sudo gpasswd -a ${USER} docker`.
3. [Configure a security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) to grant yourself ssh access to your EC2 instance.
4. Download the latest Waffle Takeout from S3
5. Upload to EC2: `rsync -avz -e "ssh -i <your key pair>.pem" --progress /path/to/waffleio-takeout.zip ec2-user@<ec2 public ip>:`
6. ssh into your ec2 instance: `ssh -i <your key pair>.pem ec2-user@<ec2 public ip>`
7. `unzip waffleio-takeout.zip`
8. `cd waffleio-takeout`
9. `./install.sh`, and follow prompts.

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
