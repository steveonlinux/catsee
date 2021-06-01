#!/bin/sh

p=$(pwd)

mkdir /home/steve/.config/catsee

mkdir /home/steve/.config/catsee/cache

cp config.sh /home/steve/.config/catsee/config.sh

ln -s "${p}/catsee.sh" /usr/bin/catsee
