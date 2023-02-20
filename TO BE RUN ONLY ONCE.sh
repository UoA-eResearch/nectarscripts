TO BE RUN ONLY ONCE

#!/bin/bash

# Name of the group everybody is in
group_name='research'
shared_folder='/mnt/'

sudo chown -R root:${group_name} ${shared_folder}
# set SETGID bit to ensure files and folders are always created with the right group id
sudo chmod -R g+s ${shared_folder}
# set ACLs to ensure that the group has always the right permissions on files and folders
sudo setfacl -Rm group:${group_name}:rwx ${shared_folder}
sudo setfacl -Rm default:group:${group_name}:rwx ${shared_folder}

