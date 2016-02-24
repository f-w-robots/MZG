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

##### Run fake arduino
  - go to http://localhost:4200
  - add new algorithm with id "fake" and code from MZG/db-code/fake-labirint.rb
  - add new interface with id "fake" and code from MZG/db-code/fake-labirint.html
  - add new devices with id "fake" and select algorithm "fake"
  - ```docker exec -it mzg_hwserver_1 ruby fake-arduino/arduino.rb fake```

#### Notes
  - On windows/osx instead http://localhost:4200 you must use http://\<docker-machine ip\>:4200, ip shows by ```docker-machine ls```
  - exec ```docker-compose build``` after pulling new code
