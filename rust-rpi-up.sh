#!/bin/bash

function fail() {

    echo "Error found: $1"
    echo "================"
    usage 1
}
function usage() {

    echo "Usage:"
    echo " rust-rpi-up [-n] -r <name or ip> [-u <user>] [-k <file>] [-p <relpath>] <project name>"
    echo " where :"
    echo "   -r=<name or ip>     RPI/SBC address or dns/mdns name (name recomended)"
    echo "   -u=<user>           Rpi user t use [default: pi]"
    echo "   -k=<file>           Key/Identity file full path for login in the PI [default: create & install keys]"
    echo "   -p=<relpath>        Relative path to create the project folder to /home/<user>/"
    echo "   -n                  Do not modify ~/.ssh/config [default: false]"

    exit $1
}

# variables
PRJ=""
RELIPATH="/home"
USER="pi"
NOCONFIG=0

echo "RUST-RPI-UP"
echo "==========="

# Parse parameters
while getopts "nr:u:k:p:" OPTION; do

    case $OPTION in
        r) 
            REMOTE=$OPTARG
            ;;
        u)
            USER=$OPTARG
            ;;

        k)
            KEY_PATH=$OPTARG
            ;;
        n)
            NOCONFIG=1
            ;;
        p)
            RP=/$OPTARG
            ;;
    esac

done

RELIPATH=$RELIPATH/$USER$RP

shift $((OPTIND-1))

[ -z $@ ] && fail "Missing project name"
[ -z $REMOTE ] && fail "Missing remote ip or name"


PRJ=$1

echo "Project:$PRJ"
echo "Remote server:$REMOTE"
echo "User:$USER"
echo "Full remote path:$RELIPATH/$PRJ"
if [ -z $KEY_PATH ] ; then
    echo "Keys will be generated and installed as $(pwd)/$PRJ/keys/$PRJ-$USER"
else
    echo "Key file:$KEY_PATH"
fi
echo "==========="
echo "checking requistes"

printf "Check ssh:"
ssh -V
[ $? -ne 0 ] && fail "SSH client not found"
printf "Check vscode insiders:"
code-insiders --version
[ $? -ne 0 ] && fail "VSCode Insiders not found"
printf "Check rsync:"
rsync --version
[ $? -ne 0 ] && fail "Rsync not found"

echo "==============="
echo "Running........"
mkdir -p $PRJ

if [ -z $KEY_PATH ] ; then
    echo "Generating  & Installing keys for the project..."
    mkdir -p $PRJ/keys
    ssh-keygen -f $(pwd)/$PRJ/keys/$PRJ-$USER -C "Key generated for project $PRJ"
    [ $? -ne 0 ] && fail "Could not generate keys"
    KEY_PATH=$(pwd)/$PRJ/keys/$PRJ-$USER
    echo "Installing keys in remote=$REMOTE password will be required..."
    ssh-copy-id -i $KEY_PATH $USER@$REMOTE
    [ $? -ne 0 ] && fail "Could not install keys on remote $REMOTE"
fi
echo "Checkong connection to the SBC..."
ssh -t -i $KEY_PATH $USER@$REMOTE 'echo connected'
[ $? -ne 0 ] && fail "Could not connect to $REMOTE"

echo "Instailling Remote SSH extension"
code-insiders --install-extension ms-vscode-remote.remote-ssh
code-insiders --install-extension ms-vscode-remote.remote-ssh-edit
code-insiders --install-extension ms-vscode-remote.remote-ssh-explorer

if [ $NOCONFIG -ne 1 ] ; then
    echo "Adding your server to .ssh/config"
    mkdir -p ~/.ssh
    touch ~/.ssh/config

    cat <<EOF >> ~/.ssh/config

    Host ${REMOTE}-${PRJ}
        HostName       ${REMOTE}
        User           ${USER}
        ForwardX11     no
        StrictHostKeyChecking no
        IdentityFile  ${KEY_PATH}
    
EOF

fi

echo "Setting up remote board"
echo "======================="
echo "Installing dependecies..."
ssh -ti -i $KEY_PATH $USER@$REMOTE "sudo apt-get update && sudo apt-get install -y git lldb curl"
[ $? -ne 0 ] && fail "Could not install dependencies. Have sudo?"
ssh -ti -i $KEY_PATH $USER@$REMOTE "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
[ $? -ne 0 ] && fail "Could not install rustup"
echo "Setting up project..."
ssh -ti -i $KEY_PATH $USER@$REMOTE "mkdir -p ${RELIPATH} && cd ${RELIPATH} && cargo new ${PRJ}"
[ $? -ne 0 ] && fail "Could not setup project ${PRJ}"
echo "Customizing project..."
ssh -ti -i $KEY_PATH $USER@$REMOT ""













