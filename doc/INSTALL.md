Waffle Takeout Installation Instructions
===
_These instructions are meant for customers installing Waffle Takeout in their own environment._

## Hardware Requirements
 - We recommend at least 32GB of storage, and 4GB of memory.
 - Takeout supports most linux distros that you can install Docker on. We test on the [latest Ubuntu Server](http://www.ubuntu.com/download/server) and the [AWS Linux AMI](https://aws.amazon.com/amazon-linux-ami/).

## Prerequisites
1. You need mongodb (v2.6) running somewhere. It's your responsibility to maintain your mongodb installation.
  - If you are running in AWS, you can install mongodb on EC2 by following [these instructions](http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/).
2. If you plan to run Waffle with a hostname (e.g., `waffle.yourcompany.com`), you'll want to set this up first so you can enter it during the initial setup.

## Installing Waffle Takeout
#### Installing Waffle Takeout on your own VM
1. [Install docker](http://docs.docker.com/installation/) on any linux distro of your choosing.
2. Upload the Takeout `.zip` to your VM that you downloaded from https://takeout.waffle.io.
3. Run `unzip <takeout zip>`.
4. Run `cd waffleio-takeout`.
5. Run `sudo ./install.sh` and follow prompts.
Remember, it's up to you to backup your mongodb database. Also, we recommend keeping a copy of /etc/waffle/environment.list somewhere safe; if anything happens to your installation, you'll be able to restore the same settings with a new install.

#### Installing Waffle Takeout on AWS

1. Follow [these instructions](https://docs.docker.com/installation/amazon/) to create an EC2 instance with docker installed.
  - The minimum EC2 instance type is `m3.large`, with 32GB storage.
  - To configure the root storage to be 32GB, instead of the default 8GB, go to the "Add Storage" tab when configuring your instance.

2. Give your ssh user access to docker.
  1. Run `docker ps`. If this errors with: `Are you trying to connect to a TLS-enabled daemon without TLS?`, then run `sudo gpasswd -a ${USER} docker`.
  2. Run `docker ps` again, to verify you have access.
3. [Configure a security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) with the following access:
  - TCP port `22`, for ssh
  - TCP ports `80` and `443`, for HTTP and HTTPS
  - If running mongodb on EC2, ensure its security group allows access to PORT `27017`.
4. Assign an [Elastic IP address](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to your instance, so your instance is always available by the same public IP. Alternatively, use the public dns name.
  - If you are using a hostname for Waffle Takeout, configure your DNS now.
5. Download the latest Waffle Takeout delivery from [takeout.waffle.io](https://takeout.waffle.io).
6. Upload the delivery to EC2: `rsync -avz -e "ssh -i <your key pair>.pem" --progress /path/to/waffleio-takeout.zip ec2-user@<ec2 public ip>:`.
7. ssh into your ec2 instance: `ssh -i <your key pair>.pem ec2-user@<ec2 public ip>`.
8. Run `unzip waffleio-takeout.zip`.
9. Run `cd waffleio-takeout`.
10. Run `sudo ./install.sh` and follow prompts.

## Proxy configuration

During installation, you'll be prompted for proxy information. If, on your internal network, you must connect through a proxy to talk to your GitHub:Enterprise installation, GitHub.com, or Rally, you should configure a proxy. If you only need GitHub:Enterprise support (and not GitHub.com or Rally integration), and reaching GitHub:Enterprise does not require connecting through a proxy, you do not need to configure a proxy.

#### Configure your proxy to allow GitHub.com access
- See GitHub's IP information: https://help.github.com/articles/what-ip-addresses-does-github-use-that-i-should-whitelist/

#### Configure your proxy to allow Rally access
- See Rally's IP information: https://help.rallydev.com/rally-ip-addresses-and-cdn-networks

## Troubleshooting

#### If `sudo ./install.sh` does not complete

##### Clean out docker containers and images
_Before running `sudo ./install.sh` again, you need to remove existing docker containers and images._

1. stop and remove any running containers: `docker rm -f $(docker ps -a -q)`
3. remove images: `docker rmi -f $(docker images -q)`

#### If the installation went fine, but the app isn't starting

##### Look at the logs from the container
1. Run `docker ps` to see if any containers are running.
2. If they are, run `docker logs waffle-app`.

#### Debugging realtime events

You can use the Poxa console to see if realtime events are being sent. The poxa console is not available with a normal install, you'll need to restart the docker container and expose the console.

Running these commands will expose the console on port `8080` on your host machine.
```
sudo service waffle-poxa stop
docker run -d --name waffle-poxa --env-file /etc/waffle/environment.list -p 8080:8080 quay.io/waffleio/poxa
sudo service waffle-nginx restart
```

Additionally, if running on CentOS, make sure that you have outbound network access on port 443. To open this port, run the following command:

```
iptables -I INPUT 3 -s 0.0.0.0/0 -d 0.0.0.0/0 -p tcp --dport 443 -m state --state New -j ACCEPT
```

Note that iptables rules need to be saved to persist after a reboot:

```
/sbin/service iptables save
```

## Reconfigure Takeout Post-Install
1. Stop and remove containers: `sudo service waffle stop`.
2. Run `sudo ./install.sh` again.

_If you need to reconfigure the URLs for GitHub.com, GitHub:Enterprise, or Rally, you need to first clear some data from the mongo database before re-running the `install.sh` script (yep, we know, we should totally handle this for you)._

1. `mongo <connect string>`
2. `use <db name>`
3. `db.migration_versions.remove({$or: [{name: /create_default_providers/}, {name: /set_public_providers/}] })`
4. `db.providers.remove({type: {$in: ['github', 'rally', 'github-enterprise']}})`

## SSL configuration
During the installation process, we create a root CA and a self-signed certificate to support SSL on your Takeout install. You will either need to (1) replace our certificates with your own certificates signed by an already trusted CA, or (2) trust our root CA in your system. If you do not, each user will be prompted to accept Waffle's self-signed certificate when the access Takeout.

#### Using your own certificates
This is the preferred way to handle SSL for Waffle Takeout. To use your own certificates, overwrite our self-signed certificate with your own trusted certificate and restart the service. The self-signed certificate live on the host machine at `/etc/waffle/nginx/certs`. If you look in that directory, you will see: `waffle-takeout.crt` and `waffle-takeout.key`. You may provide your own certs by:

1. Generate a certificate signed by a trusted CA and name it `waffle-takeout.crt`.
2. Overwrite the existing files in `/etc/waffle/nginx/certs` with the certificate you created. You must upload both the `.crt` and the `.key` file into that directory.
3. If you created your certificate using your own internal root Certificate Authority (CA), you'll need to tell Waffle about it by uploading the root CA to `/etc/waffle/ca-certificates` on the host machine.
3. Run `sudo service waffle restart` to restart Waffle Takeout using the new cert.

#### Trusting our root CA (instead of using your own)
A root CA was generated during the install process and saved on the host machine at `/etc/waffle/ca-certificates/waffle-root-ca.crt`. This is the certificate you need to trust. You have 2 options for trusing it:

1. Often times, system administrators can [trust certificates within your domain environment](https://technet.microsoft.com/en-us/library/cc754841.aspx#BKMK_adddomain). This approach will trust Waffle Takeout's self-signed certs for all machines bound to your domain. You need to ask a system administrator if this is an option for you and provide them with the certificate at `/etc/waffle/ca-certificates/waffle-root-ca.crt`.
2. Each user of Waffle Takeout can individually trust the certificate on their own machine, by following these instructions:
  - [For OSX users](https://support.apple.com/kb/PH18677?locale=en_US)
  - [For Windows users](https://technet.microsoft.com/en-us/library/cc754841.aspx#BKMK_addlocal)

### Trusting your GitHub:Enterprise certificate
Waffle will not be able to connect to your GitHub:Enterprise instance if you do not have a trusted certificate for GH:E. To get around this, place the GH:E certificate in `/etc/waffle/ca-certificates` on the host machine.
