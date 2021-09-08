#!/bin/bash

echo "Installing packages for REST"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs
sudo npm update -g npm
npm install request
