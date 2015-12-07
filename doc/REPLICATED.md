# Installing Waffle Takeout

Please submit a request on [https://takeout.waffle.io](https://takeout.waffle.io) for more information on pricing and to register for a 45 day trial.

Getting Started guides and other Waffle.io documentation can be found at [here](https://github.com/waffleio/waffle.io/wiki).

## Prerequisites

* A dedicated host with Ubuntu 14.04 or greater installed
* A Waffle Takeout license file (downloadable from [https://takeout.waffle.io](https://takeout.waffle.io))
* A GitHub Enterprise installation secured via SSL certificate. (Waffle Takeout does not support connecting to GitHub Enterprise insecurely over http at this time.)

## Host Machine

The standard setup consists of one host.

If you are using EC2 we recommend the m4.large instance type with a 32GB EBS volume.

For other setups we recommend hosts with 8 gigs of RAM and 2 CPUs.

## Network Configuration

To run Waffle Takeout, you will need to ensure the following ports are open:

| Port          | Service       | Description                                                                      |
| :------------ |:--------------| :--------------------------------------------------------------------------------|
| 8800          | Custom TCP    | This port is to access the admin dashboard for your Waffle Takeout installation  |
| 443           | HTTPS         | Web application over HTTPS access                                                |
| 80            | HTTP          | Web application access                                                           |
| 22            | SSH           | SSH access                                                                       |

## Register a GitHub OAuth app

Waffle Takeout talks to GitHub Enterprise and GitHub.com via OAuth. You will need to create an OAuth app on your GitHub Enterprise installation or GitHub.com that Waffle Takeout can connect to.

The OAuth app registered will use the network routable address to your host machine for the Homepage URL (e.g. https://waffle.company.com).

## Installation

The recommended installation of Waffle Takeout is done through running the following script on the host:

 ```curl
$ curl -sSL https://get.replicated.com | sudo sh
 ```

 This will install the management application, which takes care of downloading and installing Waffle Takeout, as well as providing a simple web interface for setting up Waffle Takeout, and for viewing runtime metrics.

 This requires access to the internet, but only during the installation process. If you are unable to allow access the internet during installation or upgrades, please contact [support@waffle.io](mailto:support@waffle.io) and we can provide you with alternate installation instructions.

 The installation process can also connect to the internet through a proxy, and only needs access to these IP addresses: `52.7.167.120` and `54.174.248.164`.

 Once the script has run you can navigate to `https://waffle.company.com:8800` to complete the setup.

 From here you can upload your trial license key, add your GitHub OAuth Application details, upload an SSL certificate and enter other configuration options.

## Maintenance

### Updating your Waffle Takeout Installation

You can check for new releases by going to the management interface dashboard `https://waffle.company.com:8800` and clicking on the 'Check Now' button. If an update is available you will be able to read the release notes and install the update.

It is also recommended to run the following commands on the host afterwards:

```curl
$ sudo apt-get update
$ sudo apt-get install replicated replicated-ui replicated-agent replicated-updater
```
