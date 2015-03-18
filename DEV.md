## Developer instructions for Waffle Takeout

### Setting up your dev environment
##### Install boot2docker:
``` bash
brew update
brew install caskroom/cask/brew-cask
brew cask install virtualbox
brew install boot2docker
boot2docker init
boot2docker up
```

Add `DOCKER_HOST` to your `~/.zshrc`:
`export DOCKER_HOST=tcp://192.168.59.103:2376`
