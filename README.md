# waffle.io-takeout
Scripts to package and install Waffle.io Takeout

## Building a shippable package
Running `./build.sh` will pull down all of the docker images, package them together in a zip file along with the install script, and upload the package to S3. You will need to have docker installed and be logged into quay.io. You can do that by running `docker login quay.io`.
