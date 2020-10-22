#!/bin/bash
set -e

apt-get install -y python3-venv zip
pushd ./$1

python3 -m venv v-env
source v-env/bin/activate
pip3 install -r requirements.txt
deactivate

pushd v-env/lib/python3.6/site-packages
zip -r9 ${OLDPWD}/$1.zip .
popd 
zip -g $1.zip main.py
popd
mv ./$1/$1.zip .