## Waffle Takeout upgrade instructions

1. Download latest Takeout delivery
2. Copy `waffleio-env.list` out of waffleio-takeout directory, for original installation
3. Remove `waffleio-takeout` directory and `waffleio-takeout.zip` from original installation
4. Upload latest Takeout delivery to VM
5. unzip `waffleio-takeout.zip`
6. copy `waffleio-env.list` into `waffleio-takeout` directory
7. Stop running docker containers: `docker rm -f $(docker ps -a -q)`
8. Remove existing docker images: `docker rmi -f $(docker images -q)`
9. run `install.sh`, which should have defaults from previous installation (pulled from `waffleio-env.list`)
