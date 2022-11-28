#! /bin/bash
version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
if [[ ! -z "$version" ]]
then
    apt install python
    echo $(python --version)
fi
