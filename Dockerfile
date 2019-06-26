FROM ros:melodic-ros-base
# install ros tutorials packages
RUN apt-get update && apt-get install -y \
    ros-melodic-ros-tutorials \
    ros-melodic-common-tutorials \
    ros-melodic-rosserial-arduino \
    ros-melodic-rosserial \
    ros-melodic-usb-cam \
    && rm -rf /var/lib/apt/lists/