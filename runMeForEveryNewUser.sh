#!/bin/bash

# Name of the group everybody is in
group_name='research'
shared_folder='/mnt/' # THIS IS NOW POINTING DIRECTLY TO THE MOUNTED RESERACH DRIVE

function display_help {
    echo ""
    echo "Usage $0 [-h] <username> <public_ssh_key_file>"
    echo "  <username>: Name of the user to be created, e.g. jche159"
    echo "  <public_ssh_key_file>: Path to the public SSH key file, matching the private key <username> is going to use to log into the VM"
    # how do they pass that keyfile on? Do they potentialy have to create one in the first place?
    echo "  -h: print this help message"
    echo ""
}

# Check arguments passed in through the command-line
if [ "$#" -lt "1" ]; then
    echo "WARNING: No command-line argument provided"
    display_help
    exit 1
elif [ "$#" -eq "1" ] && [ "$1" == "-h" ]; then
    display_help
    exit 0
elif [ "$#" -eq "2" ]; then
    user_name=$1
    pub_ssh_key_file=$2
    if [ ! -f "${pub_ssh_key_file}" ]; then
        echo "Public SSH key file '${pub_ssh_key_file}' does not exist."
        echo "Exiting..."
      exit 1
    fi
elif [ "$#" -gt "2" ]; then
    echo "WARNING: More than 2 command-line arguments provided"
    display_help
    exit 1
else
    echo "WARNING: Unexpected error"
    exit 1
fi

# Verify group ${group_name} already exists. Exit if group doesn't exist
if [ ! $(getent group "${group_name}") ]; then
    echo "Group ${group_name} does not yet exist. Needs to be created first. Exiting"
    exit 1
fi

# Create user if it does not already exists
if [ $(getent passwd "${user_name}") ]; then
    echo "User ${user_name} already exists."
else
    echo "User ${user_name} does not yet already. Creating..."
    sudo useradd --base-dir /home --shell /bin/bash ${user_name}
    authz_key_file="/home/${user_name}/.ssh/authorized_keys"
    sudo mkdir -p /home/${user_name}/.ssh
    sudo touch ${authz_key_file}
    cat "${pub_ssh_key_file}" | sudo tee --append ${authz_key_file}
    sudo chmod 600 ${authz_key_file}
    sudo chmod 700 /home/${user_name}
    sudo chown -R ${user_name}: /home/${user_name}
    sudo usermod -a -G ${group_name} ${user_name}
    echo "${user_name}  ALL=(ALL) NOPASSWD: ALL" | sudo tee --append /etc/sudoers
fi

# Create symlinks/Desktop shortcuts to improve user experience
mkdir -p ${user_name}/Desktop
if [ ! -L "/home/${user_name}/Desktop/data" ]; then
  ln -s ${shared_folder} /home/${user_name}/Desktop/data
  sudo chown ${user_name}: /home/${user_name}/Desktop/data
fi

tmp_files="opening_deeplabcut.odt mate-terminal.desktop"
for f in ${tmp_files}; do
 if [ ! -L "/home/${user_name}/Desktop/${f}" ]; then 
   ln -s /home/ubuntu/Desktop/${f} /home/${user_name}/Desktop/${f}
   sudo chown ${user_name}: /home/${user_name}/Desktop/${f}
 fi
done

# Copy shared Python environment to user's local file
if [ -f /home/ubuntu/.bashrc ]; then
    sudo cp /home/ubuntu/.bashrc /home/${user_name}/.bashrc
fi
if [ -f /home/ubuntu/.bash_profile ]; then
    sudo cp /home/ubuntu/.bash_profile /home/${user_name}/.bash_profile
fi

