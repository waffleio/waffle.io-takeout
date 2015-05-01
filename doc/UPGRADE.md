## Waffle Takeout upgrade instructions

1. Download latest Takeout delivery
2. Upload latest Takeout delivery to VM
3. SSH into the host machine
4. unzip `waffleio-takeout.zip`
5. cd into `waffleio-takeout`
6. run `cp /etc/waffle/environment.list .`
7. Shutdown Waffle: `sudo service waffle stop`
8. run `sudo ./install.sh`, which should have defaults from previous installation (pulled from `environment.list`)
