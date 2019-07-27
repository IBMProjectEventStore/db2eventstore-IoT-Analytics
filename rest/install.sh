#!/bin/bash

echo "Installing packages for REST"
curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install -y nodejs
npm install request
