#!/bin/bash

function usage()
{
cat <<-USAGE #| fmt
Description:
This script add a Linux user provided username and password. The user will be
added to the 'docker' usergroup, which will be created if not exist.

-----------
Usage: $0 [OPTIONS] [arg]
OPTIONS:
========
--username          User name of the Linux user to be added.
--password          Password of the Linux user to be added.
--WSL_admin         User name of the WSL admin.
--WSL_adminpass     Password of the WSL admin.
--IP                IP of the target WSL Server
--WSL_user          (Optional) User name of the Watson Studio Local to be added
                    [Default to Linux username if not provided]
--WSL_password      (Optional) Password of the Watson Studio Local to be added
                    [Default to Linux password if not provided]
USAGE
}

while [ -n "$1" ]; do
    case "$1" in
    -h|--help)
        usage >&2
        exit 0
        ;;
    --username)
        USER="$2"
        shift 2
        ;;
    --password)
        PASSWORD="$2"
        shift 2
        ;;
    --WSL_admin)
        WSL_ADMIN="$2"
        shift 2
        ;;
    --WSL_adminpass)
        WSL_ADMINPASS="$2"
        shift 2
        ;;
    --WSL_user)
        WSL_USER="$2"
        shift 2
        ;;
    --WSL_password)
        WSL_PASSWORD="$2"
        shift 2
        ;;
    --IP)
        IP="$2"
        shift 2
        ;;
    *)
        echo "Unknown option:$1"
        usage >&2
        exit 1
    esac
done

if [ -z ${USER} ]; then
    echo "Error: Please provide the Linux user name with --username flag"
    usage >&2
    exit 1
fi

if [ -z ${PASSWORD} ]; then
    echo "Error: Please provide the Linux user password with --password flag"
    usage >&2
    exit 1
fi

if [ -z ${WSL_ADMIN} ]; then
    echo "Error: Please provide the WSL admin user name with --WSL_user flag"
    usage >&2
    exit 1
fi

if [ -z ${WSL_PASSWORD} ]; then
    echo "Error: Please provide the WSL admin user's password with --WSL_password flag"
    usage >&2
    exit 1
fi

if [ -z ${IP} ]; then
    echo "Error: Please provide the Watson Studio Server IP with --IP flag"
    usage >&2
    exit 1
fi

if [ -z ${WSL_USER} ]; then
    WSL_USER="${USER}"
fi

if [ -z ${WSL_PASSWORD} ]; then
    WSL_PASSWORD=${PASSWORD}
fi

## Create Linux user

# add username/password
echo "Adding Linux user: ${USER}"
useradd -m "${USER}" -p "${PASSWORD}"
[ $? -ne 0 ] && echo "Error when adding user" && exit 2
# add docker usergroup
echo "Creating "
getent group docker || groupadd docker
[ $? -ne 0 ] && echo "Error when adding docker group" && exit 3
# add user to docker usergroup
usermod -aG docker "${USER}"
[ $? -ne 0 ] && echo "Error when adding user to docker group" && exit 4
# save username and file to a file
mkdir -p /home/"${USER}"
cat > /home/"${USER}"/.user_info <<EOL 
username ${USER}
password ${PASSWORD}
EOL
[ $? -ne 0 ] && echo "Error when backing up user credentials" && exit 4

## Create DSX user

# get bearer token
bearerToken=$(curl -k -X GET "https://$IP/v1/preauth/validateAuth" \
    -u $WSL_ADMIN:$WSL_PASSWORD | python -c "import sys, json; print json.load(sys.stdin)['accessToken']")
[ $? -ne 0 ] && echo "Error when getting WSL bearerToken" && exit 5

curl -i -k -X POST https://${IP}/api/v1/usermgmt/v1/user \
    -H "authorization: Bearer $bearerToken" -H "content-type: application/json" \
    -d '{ "username": "'${WSL_USER}'", "password": "'${WSL_PASSWORD}'",
    "displayName": "'${WSL_USER}'", "role": "User"}'
[ $? -ne 0 ] && echo "Error when creating WSL user." && exit 6

