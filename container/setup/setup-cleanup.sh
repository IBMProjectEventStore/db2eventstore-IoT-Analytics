#!/bin/bash -ex

##
## cleanup
##

. $(dirname $0)/apt-funcs.bash

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/ || : ignore error
rm -rf ~/.m2/repository ~/.ivy2/cache	|| : ignore error
