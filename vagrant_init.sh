#!/bin/bash

# This script will be run by Vagrant to
# set up everything necessary to use Zipline.

# Because this is intended be a disposable dev VM setup,
# no effort is made to use virtualenv/virtualenvwrapper

# It is assumed that you have "vagrant up"
# from the root of the zipline github checkout.
# This will put the zipline code in the
# /vagrant folder in the system.

VAGRANT_LOG="/home/vagrant/vagrant.log"

# Need to "hold" grub-pc so that it doesn't break
# the rest of the package installs (in case of a "apt-get upgrade")
# (grub-pc will complain that your boot device changed, probably
#  due to something that vagrant did, and break your console)

echo "Obstructing updates to grub-pc..."
apt-mark hold grub-pc 2>&1 >> "$VAGRANT_LOG"

echo "Adding python apt repo..."
apt-add-repository -y ppa:fkrull/deadsnakes-python2.7 2>&1 >> "$VAGRANT_LOG"
echo "Updating apt-get caches..."
apt-get -y update 2>&1 >> "$VAGRANT_LOG"

echo "Installing required system packages..."
apt-get -y install python2.7 python-dev g++ make libfreetype6-dev libpng-dev libopenblas-dev liblapack-dev gfortran pkg-config git 2>&1 >> "$VAGRANT_LOG"

echo "Installing ta-lib..."
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz --no-verbose -a "$VAGRANT_LOG"
tar -xvzf ta-lib-0.4.0-src.tar.gz 2>&1 >> "$VAGRANT_LOG"
cd ta-lib/
./configure --prefix=/usr 2>&1 >> "$VAGRANT_LOG"
make 2>&1 >> "$VAGRANT_LOG"
sudo make install 2>&1 >> "$VAGRANT_LOG"
cd ../

echo "Installing pip and setuptools..."
wget https://bootstrap.pypa.io/get-pip.py 2>&1 >> "$VAGRANT_LOG"
python get-pip.py 2>&1 >> "$VAGRANT_LOG"
echo "Installing zipline python dependencies..."
/vagrant/etc/ordered_pip.sh /vagrant/etc/requirements.txt 2>&1 >> "$VAGRANT_LOG"
echo "Installing zipline extra python dependencies..."
pip install -r /vagrant/etc/requirements_dev.txt -r /vagrant/etc/requirements_blaze.txt 2>&1 >> "$VAGRANT_LOG"
echo "Installing zipline package itself..."
find /vagrant/ -type f -name '*.c' -exec rm {} +
pip install -e /vagrant[all] 2>&1 >> "$VAGRANT_LOG"
echo "Finished!"
