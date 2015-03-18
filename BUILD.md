## Building Waffle Takeout
_These instructions are for Waffle developers. Customers will never build their own takeout deliveries._

Waffle Takeout relies on several independent docker images, published in [quay.io](https://quay.io/). 
The build process downloads the latest images and packages them together as a zip file. 
The resulting zip is uploaded to an S3 bucket.

For customer access to Waffle Takeout versions, login to [takeout.waffle.io](https://takeout.waffle.io). If this has not launched yet, contact the Waffle team (support@waffle.io) for a direct link. 

### Prerequisites
- docker installed locally
- [quay.io](https://quay.io/) login, with access to the waffleio org (login to quay.io with `docker login quay.io`)
- AWS environment variables

### Build steps
1. Run `./build.sh`
