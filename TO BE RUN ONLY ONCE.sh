TO BE RUN ONLY ONCE

#!/bin/bash

# Name of the group everybody is in
group_name='research'
group_id='1003'
shared_folder='/mnt/'

# Create group ${group_name} if it does not already exists
if [ ! $(getent group "${group_name}") ]; then
    echo "Group ${group_name} does not yet exist. Creating..."
    sudo groupadd -g ${group_id} ${group_name}
fi

# Create shared folder if it does not exist yet
if [ ! -d ${shared_folder} ]; then
    echo "Shared folder '${shared_folder}' does not yet exist. Creating..."
    sudo mkdir -p ${shared_folder}
fi

# install dependency package (includes setfacl command)
sudo dpkg -l acl > /dev/null
if [ "$?" -gt "0" ]; then
    echo "Installing dependency package 'acl'..."
    sudo apt-get install acl
fi

sudo chown -R root:${group_name} ${shared_folder}

# set SETGID bit to ensure files and folders are always created with the right group id
sudo chmod -R g+s ${shared_folder}

# set ACLs to ensure that the group has always the right permissions on files and folders
sudo setfacl -Rm group:${group_name}:rwx ${shared_folder}
sudo setfacl -Rm default:group:${group_name}:rwx ${shared_folder}

