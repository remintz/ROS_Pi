# Instructions

1) Start with a new SD card with raspian-stretch-lite installed and make sure you have internet access from the Raspberry Pi
2) Run the following commands to setup and install Docker
'''
sudo apt-get update
sudo apt-get install -y git
git clone xxxx ros-pi-init
cd ros-pi-init
sudo bash init.sh
'''
The install script will run and:
* will ask you for a new hostname
* create the user acn-iot with password acn-iot-pwd
* install docker
* copy the Dockerfile and docker-compose.yml files


To run ROS you will need to run:

`
docker-compose up -d
`

The first run should take a long time as the containers are downloaded.

This script runs the *talker* and *listener* applications from the ROS tutorials. You may check if they are working by running:

`
docker-compose logs listener
`

or 

`
docker-compose logs talker
`

You may stop the containers running

`
docker-compose stop
`

