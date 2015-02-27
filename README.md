# waffle.io-takeout
Scripts to package and install Waffle.io Takeout

## Building a shippable package
Running `./build.sh` will pull down all of the docker images, package them together in a zip file along with the install script, and upload the package to S3. You will need to have docker installed and be logged into quay.io. You can do that by running `docker login quay.io`.

## Installing Waffle.io Takeout
Retrieve the latest version of takeout by downloading the zip file uploaded by running `./build.sh`. Unzip the file, cd into it, and run `./install.sh`. You will be prompted for some some information about your install and then the script will take over from there.
