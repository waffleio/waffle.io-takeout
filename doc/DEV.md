# Developer instructions for Waffle Takeout

## Running Takeout locally
You must run takeout in a linux environment. This is most easily setup by using a VirtualBox image. With it running in a VM, you will need to run [ngrok](ngrok.com) on your local machine to tunnel all web traffic to your VM. 

#### Setuping up your VirtualBox
This looks more daunting than it is, I promise :)

1. Download Ubuntu (download can be found [here](http://www.ubuntu.com/download/desktop/thank-you?country=US&version=14.04.2&architecture=amd64))
2. Start up VirtualBox
3. Inside VirtualBox, click the "New" at the top left and create a new box:
  - Name: Takeout (or whatever you prefer)
  - Type: Linux
  - Version: Ubuntu (64 bit)
  - Memory size: 3 GB
  - Hard drive: "Create a virtual hard drive now"
  - Hard drive file type: VDI
  - Storage on physical hard drive: Dynamically allocated
  - File location and size: 16GB
4. Once it is created, right click on the new VirtualBox in the left column of VirtualBox Manager and select "settings"
5. Under the "Storage" tab, add a new Controller: IDE and select "Choose disk". A finder window should open. Navigate to and select the Ubuntu .iso file you downloaded in step 1.
6. Under the "Network" tab, create a new Adapter with this config:
  - Attached to: "Bridged Adapter"
  - Name: Wi-Fi (AirPort)
    - Depending on your current network, you might have to pick a hardline option.
7. Under the "Shared Folders" tab, add a new Machine Folder to the location you want to keep the takeout files on your local machine. I chose ~/Desktop/waffle-takeout. You will have to create the folder on your machine first in order to share it with the virtual machine.
  - Read-only: false
  - Auto-mount: true
  - Make Permanent: true
8. Cick OK at the bottom to save your configurations
9. Double click on the VirtualBox in the left column. It will boot and walk you through the installation process for Ubuntu.
10. After installing, while in your VM, navigate to the top menu bar of OSX and select Devices > Insert Guest Additions CD.
11. Inside the VM, you should see a window popup asking if you want to run the software on the CD. Choose "Run" and walk through the process. If it doesn't automatically run, you should be able to run it from the CD icon on the sidebar within the VM.
12. Lastly, install docker on your new VM [following these] instructions(https://docs.docker.com/installation/ubuntulinux/). After it is installed, make sure and run `sudo service docker start`.
13. Might be a good idea to reboot to make sure you are in a good state.

#### Installing Takout
1. Obtain a Takeout delivery using one of the following options.
  1. Downloading it from S3
  2. Generate one by running the `./bin/build.sh` script (if you are testing local changes, you have to use this option).
2. Unzip it on your host (local) machine into the location you specified in step 7 of "Setting up your VirtualBox"
3. Inside your guest (virtual) machine, open a terminal and `cd /media/sf_<name of shared folder>`
4. Run `sudo ./install` and follow the install.
  - You must specify a hostname and configure ngrok (explained below) to tunnel traffic to your VM.
  - For your mongo uri, run `mongod` on your host (local) machine and then use the IP for your host machine.

#### Configure ngrok
Waffle has a team ngrok account. You need to request access to it if you don't have it already. Then follow these steps:

1. Download ngrok (optionally add it to your path or move it into `/usr/local/bin/` for convenience).
2. Run `ngrok authtoken <your ngrok auth token>`. This will create `~/.ngrok2/ngrok.yml`.
3. Open `~/.ngrok2/ngrok.yml` in your editor of choice and add the config so your file looks something like this (of course replacing the things in `<...>`):
  ```yml
    authtoken: <your auth token>

    tunnels:
      takeout:
        addr: <your VM IP>:443
        hostname: <your VM hostname>
        proto: tls

      takeout-subdomains:
        addr: <your VM IP>:443
        hostname: "*.<your VM hostname>"
        proto: tls
  ```
4. Save that file and run `ngrok start --all` from your terminal.

## Updating docker images
_Pushes to master trigger docker builds in quay.io, these steps are not required during normal development._

1. Build the docker image: `docker build --tag="waffleio/waffle.io-app" --no-cache .` (the `no-cache` option is required for now, otherwise new code changes won't be picked up).
2. Grab the image id from the output.
3. Tag the image for quay.io: `docker tag -f <image id> quay.io/waffleio/waffle.io-app`
4. Upload to quay.io: `docker push quay.io/waffleio/waffle.io-app`

Of course, replace `waffleio/waffle.io-app` with the repo in question.
