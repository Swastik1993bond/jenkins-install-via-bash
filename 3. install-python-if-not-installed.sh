#! /bin/bash
cd /opt/SW/Jenkins
version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
if [[ -z "$version" ]]
then
    apt install python -y
fi
