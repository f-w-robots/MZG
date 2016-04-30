# MZG
Web Server API

## How to start

#### Installation
  - install [docker](https://docs.docker.com/linux/step_one/) and [docker-compose](https://docs.docker.com/compose/install/) for linux, or [docker-toolbox](https://www.docker.com/products/docker-toolbox) for windows/os x
  - clone repository
  - exec ```docker-compose up``` into repository folder

#### Usage
  - ```docker-compose up```
  - http://localhost:4200 - web interface

#### Notes
  - On windows/osx instead http://localhost:4200 you must use http://\<docker-machine ip\>:4200, ip shows by ```docker-machine ls```
  - exec ```docker-compose build``` after pulling new code
