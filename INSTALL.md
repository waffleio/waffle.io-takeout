# Installing Waffle Takeout

Go to [https://takeout.waffle.io](https://takeout.waffle.io) for more information on pricing and to sign up for a free 45 day trial.

Getting Started guides and other Waffle.io documentation can be found [here](https://github.com/waffleio/waffle.io/wiki).

## Installation Types
* [Bring Your Own
  Server](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#installation)
* [Air
  Gap](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#airgap-installation)
* [Amazon
  AMI](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#ami-installation)

# Prerequisites

* A supported Linux server (modern versions of Ubuntu, Debian, CentOS, Red Hat & Fedora)
* A Waffle Takeout license file (downloadable from [https://takeout.waffle.io](https://takeout.waffle.io))
* A GitHub Enterprise installation secured via SSL certificate. (Waffle Takeout does not support connecting to GitHub Enterprise insecurely over HTTP at this time.)

## Host Machine

The standard setup consists of one host.

If you are using EC2, we recommend the m4.large instance type with at least a 32GB EBS volume.

For other setups we recommend hosts with 8 gigs of RAM and 2 CPUs.

## Network Configuration

To run Waffle Takeout, you will need to ensure the following ports are open:

| Port          | Service       | Description                                                                      |
| :------------ |:--------------| :--------------------------------------------------------------------------------|
| 8800          | Custom TCP    | This port is to access the admin dashboard for your Waffle Takeout installation  |
| 9880          | Custom TCP    | This port is for replicated host api to update the admin dashboard's status      |
| 443           | HTTPS         | Web application over HTTPS access                                                |
| 80            | HTTP          | Web application access                                                           |
| 22            | SSH           | SSH access                                                                       |

## Register a GitHub.com OAuth app

Waffle Takeout talks to GitHub Enterprise and GitHub.com via OAuth. You will need to create an OAuth application on your GitHub Enterprise installation or GitHub.com that Waffle Takeout can connect to.

#### For GitHub Enterprise

To register an OAuth application, first click on your profile icon. From there, navigate to Settings->Applications and to the Developer Applications tab. Select 'Register New Application.'

Make sure the Homepage URL and Authorization Callback match the URL for your Waffle Takeout installation: `https://waffle.company.com` (just the base url for where it's installed, no special path required).

When configuring your GitHub Enterprise url on the admin settings page, make sure to include the protocol ("https://") in the url.

## Installation

#### 1. SSH into your Linux server
#### 2. Run the following script:

 ```curl
$ curl -sSL https://takeout.waffle.io/get | sudo bash
 ```

#### 3. Access your server via HTTPS on port 8800 & bypass the SSL security warning.

![Step 3](doc/screenshots/1.png)

#### 4. Upload a custom TLS/SSL cert/key or proceed with the provided self-signed pair.

![Step 4](doc/screenshots/2.png)

#### 5. Upload the provided license file (.rli)

![Step 5](doc/screenshots/3.png)


#### <a name="step6">6</a>. Secure your Waffle Takeout Management console with a password

![Step 6](doc/screenshots/4.png)

#### 7. Configure your Waffle Takeout instance

![Step 7](doc/screenshots/5.png)

#### 8. Migrating your old database
_Skip to [step 9](INSTALL.md#9-click-save) unless you are migrating from Waffle Takeout 1.x with the bash installation script._

Upgrading from Takeout 1.x to Takeout 2.x requires configuring the new installation with your existing database information. Check the optional "Migrate" checkbox near the bottom of the "Settings" page. Provide the "MongoDB URI", "Encryption Key", and "Signing Key" from your existing installation. These are found in your `/etc/waffle/environment.list` file on your host machine.

![Migrate Database](doc/screenshots/mongo-migration-settings.png)

#### 9. Click "Save"
_NOTE: Make sure you have finished configuring your install before starting the instance._

After clicking "Save" at the bottom of the settings page, the instance will start.

#### 10. Visit the hostname you provided to access Waffle Takeout

![Step 10](doc/screenshots/6.png)

### Airgap Installation

**If you need an airgap installation, please contact us at <takeout@waffle.io> so we can provide you with a download link and instructions for getting a Waffle Takeout `.airgap` package.**

For installations who don't have easy access to the internet, you can install Waffle Takeout using the following steps. These installations are "airgapped" meaning that they "do not have inbound or outbound internet traffic at all". Waffle Takeout supports this using Replicated's airgap feature.

> __Note__: You will need to provision a host machine as [noted above](INSTALL.md#host-machine), but with at least 64G of space for this install as opposed to the 32G mentioned.

#### 1. Follow the [Replicated Airgap install docs](http://docs.replicated.com/docs/airgapped-installations#2-install-replicated). You will need to up the default base device size for Docker to 20G. You can do so by adding the following to `/etc/docker/default`.

```bash
DOCKER_OPTS="--storage-opt dm.basesize=20G"
```

Once that change is made, restart the docker daemon (Ubuntu/Debian):

```bash
sudo service docker stop
sudo rm -rf /var/lib/docker
sudo service docker start
```

#### 2. The Airgap package is what is downloaded from the Airgap link we provide you. You can `shift-click` in your browser to download the file or you can use something like `wget`.

```bash
wget --trust-server-names -O <your_file_name>.airgap "<link_we_provide>"
```

#### 3. Once you have the host machine up and running and have installed docker and replicated, upload the `.airgap` package onto the host machine and remember the path to the file. One way is to use `scp` on your computer to upload the file to the host machine.


```bash
scp -i ~/.ssh/your_key.pem /path/to/your_airgap_file.airgap ubuntu@<host_machine_url>:/path/to/upload/to
```

> Note: You may need to run the following commands on the host machine to restart the Management Screen UI (Ubuntu/Debian)

```
sudo service replicated restart
sudo service replicated-ui restart
sudo service replicated-operator restart
```

#### 4. Continue following the [Replicated Airgap install docs](http://docs.replicated.com/docs/airgapped-installations) to locate the package on the host machine and upload your license in the management ui.

#### 5. Follow the above steps for installing Waffle Takeout starting from [Step 6](#step6)

### AMI Installation
* We provide AMI's which allow you to skip the replicated installation
* Before launching an AMI, ensure you've got the following:
  * A [Waffle Takeout license](https://takeout.waffle.io/)
  * [Github Registered OAuth App](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#register-a-githubcom-oauth-app)
  * An appropriate [Security Group Configuration](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#network-configuration)

#### How To Install using an AMI
1. Click any of the links below to fire up the EC2 console and get started with
  an AMI
| Region         | AMI ID |
|----------------|--------|
| ap-northeast-1 | [ami-5fd9033e](https://console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#LaunchInstanceWizard:ami=ami-5fd9033e) |
| ap-northeast-2 | [ami-8fa97de1](https://console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#LaunchInstanceWizard:ami=ami-8fa97de1) |
| ap-southeast-1 | [ami-3e55f25d](https://console.aws.amazon.com/ec2/v2/home?region=ap-southeast-1#LaunchInstanceWizard:ami=ami-3e55f25d) |
| ap-southeast-2 | [ami-00251763](https://console.aws.amazon.com/ec2/v2/home?region=ap-southeast-2#LaunchInstanceWizard:ami=ami-00251763) |
| eu-central-1   | [ami-84ed13eb](https://console.aws.amazon.com/ec2/v2/home?region=eu-central-1#LaunchInstanceWizard:ami=ami-84ed13eb) |
| eu-west-1      | [ami-5796d424](https://console.aws.amazon.com/ec2/v2/home?region=eu-west-1#LaunchInstanceWizard:ami=ami-5796d424) |
| sa-east-1      | [ami-39fe6355](https://console.aws.amazon.com/ec2/v2/home?region=sa-east-1#LaunchInstanceWizard:ami=ami-39fe6355) |
| us-east-1      | [ami-e96229fe](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:ami=ami-e96229fe) |
| us-west-1      | [ami-1f1b537f](https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#LaunchInstanceWizard:ami=ami-1f1b537f) |
| us-west-2      | [ami-6c05de0c](https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#LaunchInstanceWizard:ami=ami-6c05de0c) |

1. Continue with step 3 of the [installation instructions](https://github.com/waffleio/waffle.io-takeout/blob/master/INSTALL.md#installation)

#### AMI Information
* Consult AWS for pricing information when using EC2 Instances
* The AMI is built on a standard ubuntu 16.04 image
* Should there be any need to ssh into the node for troubleshooting, utilize the
  key pair you assigned to the instance with the `ubuntu` user

## Maintenance

### Backups

Waffle Takeout automatically takes snapshots of the application state and database every 24 hours. These snapshots can be used to restore your Takeout installation in the event that something happens to the host machine or the installation itself. Snapshots are stored in `/var/lib/replicated/snapshots` on the host machine. It is highly recommended that you copy these backups to another location each day so that you are not at risk of losing them along with your installation in the event the host machine encounters complications.

#### Restoring Waffle data

Please use the following instructions for restoring your Waffle Takeout instance:

Refer to the Replicated documentation for restoring your Replicated instance - https://www.replicated.com/docs/kb/supporting-your-customers/restoring-from-a-snapshot.

To complete a restore, you will need to do the following steps to restore your existing Waffle data including projects, cards, etc.

Once the Replicated restore was successful and the application has been started, you will need to run the following to get a list of the running containers:

```bash
sudo docker ps
```

Find the CONTAINER ID of the container using the image name `takeout-mongo`. Once you have that id, run the following command to get access to that container:

```bash
sudo docker exec -it <CONTAINER ID> /bin/bash
```

In the container, you will need to connect to the database using the mongo shell.

```bash
mongo
```

In the mongo shell, you will need to drop the `waffle-takeout` database.

```bash
use waffle-takeout
db.dropDatabase();
exit # exit mongo shell
exit # exit takeout-mongo container
```

This deletes the empty database created for you when first starting a new Waffle Takeout instance. We would now like to restore your existing Waffle data that was backed up as part of the Replicated snapshot.

On the host machine, we can run the following command to restore your existing Waffle data:

```bash
replicated admin restore-mongodb
```

Once that completes, you will be able to access Waffle Takeout and see your existing data.

### Updating your Waffle Takeout Installation

Update the Replicated agent on the host machine before upgrading the Waffle Takeout application. You can update all Replicated component versions by re-running the installation script.:

```curl
$ curl -sSL https://takeout.waffle.io/get | sudo bash
```

You can check for new app releases by going to the management interface dashboard `https://waffle.company.com:8800` and clicking on the 'Check Now' button. If an update is available you will be able to read the release notes and install the update.

#### Updating an Airgap installation

To update an Airgap installation, you will need to download a new package via a link that we provide you and upload it to the server location specified in the "Console Settings" in the management ui.

![Airgap Settings](doc/screenshots/8.png)

To download the package onto your computer, you can use something similar to `wget`:

```bash
wget --trust-server-names -O <your_update>.airgap "<link_we_provide>"
```

Then to upload the package onto the host machine, you can use something similar to `scp`:

```bash
scp -i ~/.ssh/your_key.pem /path/to/updated_package.airgap ubuntu@<host_machine_url>:/path/to/updates
```

On the dashboard in the management ui, you can now click "Check Now" and should see the new update to install.

## Migrating from 1.x (self-install) to 2.x (Replicated install)
_NOTE: Upgrading from Waffle Takeout 1.x to Waffle Takeout 2.x requires an additional configuration step before starting Takeout. This is documented in [step 8](INSTALL.md#8-migrating-your-old-database) above._

Starting with Waffle Takeout 2.x, installation changed to use [Replicated](http://www.replicated.com) instead of the custom installation bash script. If you installed Waffle Takeout by downloading a zip file and manually running an installation script, you'll need to migrate to the Replicated installation method. You can do that by following the [installation instructions](INSTALL.md#installation) above.
