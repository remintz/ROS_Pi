# ROS-Pi

This repository contains the scripts to install the [Robot Operating System - ROS](https://www.ros.org/) on a Raspberry Pi using docker containers.

It is currently based on the ROS version **Melodic**.

## Instructions

1) Start the Raspberry Pi with a new SD card with raspian-stretch-lite installed and make sure you have internet access from it.
2) Run the following commands to setup and install Docker
`
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/remintz/ROS_Pi.git
cd ros-pi
sudo bash init.sh
`

The install script will run and:
* will ask you for a new hostname
* create the user **acn-iot** with password **acn-iot-pwd**
* change the password for user **pi** to **$howC@se1700!!!**
* install docker and docker-compose
* copy the *Dockerfile* and *docker-compose.yml* files to */home/acn-iot*
* reboot

The new login should be done with user **acn-iot** and password **acn-iot-pwd**

To run ROS you will need to run:

`
docker-compose up -d
`

The first run should take a long time as the containers are downloaded.

This script runs the **talker** and **listener** applications from the ROS tutorials. You may check if they are working by running:

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

