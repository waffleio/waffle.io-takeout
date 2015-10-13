## Waffle Takeout upgrade instructions

#### Upgrading from `waffleio-takeout-2015-05-27-12:05:32` (takeout alpha) to `v1.0.0` (Oct, 2015)

1. Download latest Takeout delivery
2. Upload latest Takeout delivery to VM
3. SSH into the host machine
4. remove previous `waffleio-takeout` directory and zipfile
5. unzip `waffleio-takeout.zip`
6. cd into `waffleio-takeout`
7. backup your existing environment file: run `cp /etc/waffle/environment.list /etc/waffle/environment.list.bak`
9. Shutdown Waffle: `sudo service waffle stop`
10. run `sudo ./install.sh`, which will use defaults from previous installation (pulled from `/etc/waffle/environment.list`)
