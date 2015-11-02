# Installing Waffle Takeout

Please submit a request on [https://takeout.waffle.io](https://takeout.waffle.io) for more information on pricing and to register for a 45 day trial.

Getting started guides and other Waffle.io documentation can be found at [here](https://github.com/waffleio/waffle.io/wiki).

## Prerequisites

* One dedicated host with Ubuntu 14.04 or greater installed
* A Waffle.io Takeout license file
* A GitHub Enterprise or GitHub.com application

## Host Machine

The standard setup consists of one host, running the following services:

* Migrations
* Poxa
* Rally
* Hedwig
* Hooks
* API
* App
* Nginx

If you are using EC2 we recommend the c3.2xlarge instance types.

For other setups we recommend hosts with 16 gigs of RAM and 8 CPUs.

## Register a GitHub OAuth app

Waffle Takeout talks to GitHub Enterprise and GitHub.com via OAuth. You will need to create an OAuth app on your GitHub Enterprise installation or GitHub.com that Waffle Takeout can connect to.

The OAuth app registered will use the domain name pointing to your Platform host for the Homepage URL (e.g. https://waffle-io.your-domain.com).

## Installation

### Creating a Security Group

If you're setting up your AMI for the first time you will need to create a Security Group. From the EC2 management console, create an entry for each port in the table below:

| Port          | Service       | Description                                                                  |
| ------------- |:-------------:| ----------------------------------------------------------------------------:|
| 8800          | Custom TCP    | This port is to access the admin dashboard for your Enterprise installation. |
| 443           | HTTPS         | Web application over HTTPS access.                                           |
| 80            | HTTP          | Web application access.                                                      |
| 22            | SSH           | SSH access                                                                   |

### Installation

The recommended installation of the Platform host is done through running the following script on the host:

 ```curl
$ curl -sSL https://get.replicated.com | sudo sh
 ```

 This will install the management application, which takes care of downloading and installing Waffle Takeout, as well as providing a simple web interface for setting up the platform, and for viewing runtime metrics.

 Once the script has run you can navigate to `https://waffle-io.your-domain.com:8800` to complete the setup.

 From here you can upload your trial license key, add your GitHub OAuth details, upload an SSL certificate and enter other configuration options.

 If you are running the Platform host on EC2, we recommend using an image that uses EBS for the root volume, as well as allocating 30 gigs of space to it. It is also recommended to not destroy the volume on instance termination.

## Maintenance

### Updating your Waffle Takeout Installation

You can check for new releases by going to the management interface dashboard `https://waffle-io.your-domain.com:8800` and clicking on the 'Check Now' button. If an update is available you will be able to read the release notes and install the update.

It is also recommended to run the following commands on the Platform host afterwards:

```curl
$ sudo apt-get update
$ sudo apt-get install replicated replicated-ui replicated-agent replicated-updater
```
