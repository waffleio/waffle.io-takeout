# waffle.io-takeout
Scripts to package and install Waffle.io Takeout

## Building a shippable package
Running `./build.sh` will pull down all of the docker images, package them together in a zip file along with the install script, and upload the package to S3. You will need to have docker installed and be logged into quay.io. You can do that by running `docker login quay.io`.

## Installing Waffle.io Takeout
Retrieve the zip file containing the latest version of takeout from S3. You will need to clear out any waffle specific environment variables you set in your `.bash_profile` or `.zshrc` file and restart your terminal before continuing. Unzip the file, cd into it, and run `./install.sh`. You will be prompted for some some information about your install and then the script will take over from there.

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
