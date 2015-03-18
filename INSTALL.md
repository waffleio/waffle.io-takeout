## Waffle Takeout Installation Instructions
_These instructions are meant for customers installing Waffle Takeout in their own environment._

#### Hardware Requirements
 - We recommend at least 16GB of storage, and 3GB of memory.
 - Takeout supports any unix based distro with docker installed.
 
#### Prerequisites
1. You need mongodb (v2.6) running somewhere. It's your responsibility to maintain your mongodb installation.
  - If you are running in AWS, you can install mongodb on EC2 by following [these instructions](http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/).
2. If you plan to have your Waffle Takeout instance available through a hostname instead of an IP address (e.g., mapping the machine to waffle.io on your local network), you should have that complete before running the `install.sh` script.

### Installing Waffle.io Takeout on EC2

1. Follow [these instructions](https://docs.docker.com/installation/amazon/) to create an EC2 instance with docker installed.
  - The minimum EC2 instance type is `t2.small`, with 16GB storage.
  - To configure the root storage to be 16GB, instead of the default 8GB, go to the "Add Storage" tab when configuring your instance.

2. Give your ssh user access to docker.
  1. Run `docker ps`. If this errors with: `Are you trying to connect to a TLS-enabled daemon without TLS?`, then run `sudo gpasswd -a ${USER} docker`.
  2. Run `docker ps` again, to verify you have access.
3. [Configure a security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) with the following access:
  - TCP port `22`, for ssh
  - TCP ports `80` and `443`, for HTTP and HTTPS
  - If running mongodb on EC2, ensure its security group allows access to PORT `27017`.
4. Assign an [Elastic IP address](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to your instance, so your instance is always available by the same public IP. Alternatively, use the public dns name.
  - if you are planning to use a hostname, configure your network to use this IP address now.
5. Download the latest Waffle Takeout delivery from [takeout.waffle.io](https://takeout.waffle.io). If this site isn't live yet, ask support@waffle.io for the latest takeout delivery.
6. Upload the delivery to EC2: `rsync -avz -e "ssh -i <your key pair>.pem" --progress /path/to/waffleio-takeout.zip ec2-user@<ec2 public ip>:`.
7. ssh into your ec2 instance: `ssh -i <your key pair>.pem ec2-user@<ec2 public ip>`.
8. Run `unzip waffleio-takeout.zip`.
9. Run `cd waffleio-takeout`.
10. Run `./install.sh`, and follow prompts.

### Troubleshooting

#### If `./install.sh` does not complete

##### Clean out docker containers and images
_Before running `install.sh` again, you need to remove existing docker containers and images._

1. stop and remove any running containers: `docker rm -f $(docker ps -a -q)`
3. remove images: `docker rmi -f $(docker images -q)`

#### If the installation went fine, but the app isn't starting

##### Look at the logs from the container
1. Run `docker ps` to see if any containers are running.
2. If they are, find the id for the `waffle.io-app` container, and run `docker logs <container id>`.

### To reconfigure your Takeout
1. Stop and remove containers: `docker rm -f $(docker ps -a -q)`.
3. Run `./install.sh` again.
