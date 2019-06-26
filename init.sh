#!/bin/bash

echo -e "--------------------------------------------------------------------------"
echo -e "Initializing the ROS device"
echo -e "--------------------------------------------------------------------------"
echo -e "\n- Make sure it is connected to the Internet... "
echo -e "(probably use an ethernet cable at this point)"
echo -en "\n\n-- Press any key to continue --"; read -n 1 cont; echo

#####################################################################################
## GATHERING USER INPUT
#####################################################################################

echo -e "--------------------------------------------------------------------------"
echo -e " Gathering system configuration input"
echo -e "--------------------------------------------------------------------------"

REPO_DIR=$(pwd)
TMP_DIR=/home/pi

echo -e "REPO_DIR: $REPO_DIR"
echo -e "HOME: $HOME"

# ----- Refresh System --------------------------------------
refreshSystem=1

# ----- Setting up US Locale & Keyboard ---------------------
setupLocale=1

# ----- change pi password --------------------------------
changePiPwd=1
piPassword='$howC@se1700!!!'

# ----- Setup New user ------------------------------------
setupPrimaryUser=1
user='acn-iot'
userFullName='acn-iot'
password='acn-iot-pwd'

# ----- Setup hostname --------------------------------------
setupHostname=1
cont="n"

while [ "$cont" != "y" ] && [ "$cont" != "Y" ]; do
	echo -n "Enter new hostname: "; read newHostname
	echo -n "Hostname ok [y/n]? "; read -n 1 cont; echo
done
echo -e "\n"

#####################################################################################
## RERESH SYSTEM WITH APT-GET LIBRARY UPDATE & UPGRADE
#####################################################################################

if [ "$refreshSystem" == "1" ]; then
	echo -e " Updating APT-GET libraries and installed packages..."
    echo -e "--------------------------------------------------------------------------"
	sudo apt-get -y update 							# Update library
	if [ $? -eq 0 ]; then
		echo -e "\n\nAPT-GET update complete\n\n"
	else
		echo -e "\n\nAPT-GET update failed\nRun again later.\n\n"
		exit 1
	fi
	echo -e "\n\nAPT-GET update complete\n\n"
fi

#####################################################################################
## ADJUSTING SYSTEM SETTINGS
#####################################################################################

if [ "$setupLocale" == "1" ]; then
	echo -e " Setting US locale and keyboard..."
    echo -e "--------------------------------------------------------------------------"
	sudo cp -f locale.gen /etc/locale.gen 		# Set locale to US
	sudo cp -f keyboard /etc/default/keyboard		# Set keyboard layout to US
	echo -e "\n\nUS Locale & Keyboard setup complete\n\n"
fi

#####################################################################################
## SETTING UP USER ENVIRONMENT
#####################################################################################

if [ "$setupPrimaryUser" == "1" ]; then
	echo -e " Setting up new primary user..."
    echo -e "--------------------------------------------------------------------------"

	if [ "$user" != "" ]; then
		sudo adduser "$user" --gecos "$userFullName, , , " --disabled-password
		echo "$user:$password" | sudo chpasswd
		
		# Configuring user environment
		sudo cp -f files/.bashrc /home/"$user"/					# Set bash environment
		sudo cp -f files/.nanorc /home/"$user"/					# Set bash environment
		sudo chown "$user":"$user" /home/"$user"/.bashrc
		sudo chown "$user":"$user" /home/"$user"/.nanorc
		
		# Setting up sudo rights
		echo -e "$user ALL=(ALL) NOPASSWD: ALL" > ./"$user"
		sudo chown -R root:root ./"$user"
		sudo chmod 440 ./"$user"
		
		sudo mv -f ./"$user" /etc/sudoers.d

		NEW_HOME=/home/"$user"

		echo -e "\n\nUser environment setup complete\n\n"
	fi
fi

#####################################################################################
## Changing Pi Password
#####################################################################################

if [ "$changePiPwd" == "1" ]; then
	echo -e " Changing Pi Password..."
    echo -e "--------------------------------------------------------------------------"

	echo "pi:$piPassword" | sudo chpasswd
	echo -e "\n\npi user password changed...\n\n"
fi

#####################################################################################
## Install docker
#####################################################################################
cd $TMP_DIR

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

curl -sSL https://get.docker.com | sh
usermod -aG docker acn-iot

#####################################################################################
## Install docker-compose
#####################################################################################
cd $TMP_DIR
sudo apt-get -y install python-setuptools && sudo easy_install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && sudo python3 get-pip.py
apt-get install -y python-dev python3-dev python-setuptools python3-setuptools
sudo pip3 install requests==2.14.2
pip3 install docker-compose==1.23.2

#####################################################################################
## copy files
#####################################################################################
cd $NEW_HOME
cp $REPO_DIR/Dockefile .
cp $REPO_DIR/docker-compose.yml .

#####################################################################################
## Set up new hostname
## --- Thanks to raspi-config, published under the MIT license
#####################################################################################

if [ "$setupHostname" == "1" ]; then
	echo -e " Setting up new host name..."
    echo -e "--------------------------------------------------------------------------"
	
	currentHostname=`sudo cat /etc/hostname | tr -d " \t\n\r"`
	if [ $? -eq 0 ]; then
		echo $newHostname > ~/hostname
		mv -f ~/hostname /etc
		cp /etc/hosts ~
		sed -i "s/127.0.1.1.*$currentHostname/127.0.1.1\t$newHostname/g" ~/hosts
		mv -f ~/hosts /etc
		set HOSTNAME="$newHostname"
	fi
	echo -e "\n\nHostname setup complete"
fi

#####################################################################################
## Reboot the machine
#####################################################################################

echo -e "--------------------------------------------------------------------------"
echo -e " The ROS box is going to reboot now!"
echo -e "--------------------------------------------------------------------------"
sleep 5
shutdown -r now
