## Waffle Takeout Installation Instructions
_These instructions are meant for customers installing Waffle Takeout in their own environment._

#### Hardware Requirements
 - We recommend at least 16GB of storage, and 4GB of memory.
 - Takeout supports any linux distro with docker installed.

#### Prerequisites
1. You need mongodb (v2.6) running somewhere. It's your responsibility to maintain your mongodb installation.
  - If you are running in AWS, you can install mongodb on EC2 by following [these instructions](http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/).
2. If you plan to have your Waffle Takeout instance available through a hostname instead of an IP address (e.g., mapping the machine to waffle.io on your local network), you should have that complete before running the `install.sh` script.

### Installing Waffle.io Takeout on your own VM
1. [Install docker](http://docs.docker.com/installation/) on any linux distro of your choosing.
2. Upload waffle-takeout.zip to your VM. You should have received a link to download takeout; if not, contact support@waffle.io.
3. Run `unzip waffleio-takeout.zip`.
4. Run `cd waffleio-takeout`.
5. Run `sudo ./install.sh` and follow prompts.
Remember, it's up to you to backup your mongodb database. Also, we recommend keeping a copy of /etc/waffle/environment.list somewhere safe; if anything happens to your installation, you'll be able to restore the same settings with a new install.

### Installing Waffle.io Takeout on EC2

1. Follow [these instructions](https://docs.docker.com/installation/amazon/) to create an EC2 instance with docker installed.
  - The minimum EC2 instance type is `m3.large`, with 16GB storage.
  - To configure the root storage to be 16GB, instead of the default 8GB, go to the "Add Storage" tab when configuring your instance.

2. Give your ssh user access to docker.
  1. Run `docker ps`. If this errors with: `Are you trying to connect to a TLS-enabled daemon without TLS?`, then run `sudo gpasswd -a ${USER} docker`.
  2. Run `docker ps` again, to verify you have access.
3. [Configure a security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) with the following access:
  - TCP port `22`, for ssh
  - TCP ports `80` and `443`, for HTTP and HTTPS
  - If running mongodb on EC2, ensure its security group allows access to PORT `27017`.
4. Assign an [Elastic IP address](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to your instance, so your instance is always available by the same public IP. Alternatively, use the public dns name.
  - you must configure your network to point your Waffle Takeout hostname to this IP address now.
5. Download the latest Waffle Takeout delivery from [takeout.waffle.io](https://takeout.waffle.io). If this site isn't live yet, ask support@waffle.io for the latest takeout delivery.
6. Upload the delivery to EC2: `rsync -avz -e "ssh -i <your key pair>.pem" --progress /path/to/waffleio-takeout.zip ec2-user@<ec2 public ip>:`.
7. ssh into your ec2 instance: `ssh -i <your key pair>.pem ec2-user@<ec2 public ip>`.
8. Run `unzip waffleio-takeout.zip`.
9. Run `cd waffleio-takeout`.
10. Run `sudo ./install.sh` and follow prompts.

### Proxy configuration

During installation, you'll be prompted for proxy information. If, on your internal network, you must connect through a proxy to talk to your GitHub:Enterprise installation, GitHub.com, or Rally, you should configure a proxy. If you only need GitHub:Enterprise support (and not GitHub.com or Rally integration), and reaching GitHub:Enterprise does not require connecting through a proxy, you do not need to configure a proxy.

#### Configure your proxy to allow GitHub.com access
- See GitHub's IP information: https://help.github.com/articles/what-ip-addresses-does-github-use-that-i-should-whitelist/

#### Configure your proxy to allow Rally access
- See Rally's IP information: https://help.rallydev.com/rally-ip-addresses-and-cdn-networks

### Troubleshooting

#### If `sudo ./install.sh` does not complete

##### Clean out docker containers and images
_Before running `sudo ./install.sh` again, you need to remove existing docker containers and images._

1. stop and remove any running containers: `docker rm -f $(docker ps -a -q)`
3. remove images: `docker rmi -f $(docker images -q)`

#### If the installation went fine, but the app isn't starting

##### Look at the logs from the container
1. Run `docker ps` to see if any containers are running.
2. If they are, run `docker logs waffle-app`.

### To reconfigure your Takeout
1. Stop and remove containers: `sudo service waffle stop`.
2. Run `sudo ./install.sh` again.

_If you need to reconfigure the URLs for GitHub.com, GitHub:Enterprise, or Rally, you need to first clear some data from the mongo database before re-running the `install.sh` script (yep, we know, we should totally handle this for you)._

1. `mongo <connect string>`
2. `use <db name>`
3. `db.migration_versions.remove({$or: [{name: /create_default_providers/}, {name: /set_public_providers/}] })`
4. `db.providers.remove({type: {$in: ['github', 'rally', 'github-enterprise']}})`

### SSL configuration
During the installation process, we create a root CA and a set of self-signed certs to suport SSL on your Takeout install. You will either need to trust our root CA in your system, or replace our certificates with your own certificates signed by an already trusted CA.

_NOTE: If you do not take one of the following actions, some features in Waffle may not function properly._

#### Trusting our root CA
A root CA was generated during the install process and saved on the host machine at `/etc/waffle/ca-certificates/waffle-root-ca.crt`. You will need to ask a system administrator to trust this certificate in your system.

#### Using your own certificates
Self-signed certificates were created during the install process and saved on the host machine at `/etc/waffle/nginx/certs`. If you look in that directory, you will see 4 files: `<hostname>.crt`, `<hostname>.key`, `*.<hostname>.crt`, and `*.<hostname>.key`. You may provide your own certs by:

1. Generate certificates signed by a trusted CA for both `<hostname>.crt` and `*.<hostname>.crt` where `hostname` is the hostname of the host machine running waffle. Those names must be exact.
2. Overwrite the existing files in `/etc/waffle/nginx` with the certificates you created. You must upload both the `.crt` and the `.key` files.
