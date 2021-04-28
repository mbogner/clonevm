#!/bin/bash
# script to clone a vm and reset data on it

ORIG=$1
NAME=$2

STIME=20

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

#######
# usage
#######
if [[ "$ORIG" == "" || "$NAME" == "" ]]; then
  echo "usage: $0 <orig> <name>"
  exit 1
fi

########
# header
########
echo "##################################################"
echo "# clone $ORIG to $NAME"
echo "##################################################"

#####################
# check preconditions
#####################
function check {
  local code=$1
  local exp=$2
  local ec=$3
  if [[ "$code" == "$exp" ]]; then
    echo -e "${GREEN}ok${NC}"
  else
    echo -e "${RED}failed${NC}"
    exit $ec
  fi
}

echo -n "checking if source $ORIG exists..."
virsh list --all | grep $ORIG >> /dev/null 2>&1
check $? 0 2


echo -n "checking if target $NAME doesn't exist..."
virsh list | grep $NAME >> /dev/null 2>&1
check $? 1 3

echo -e "${GREEN}preconditions met. next step will suspend $ORIG, make a clone named $NAME and reset the clone. the reset will require sudo privileges${NC}"
read -p "[Press enter to continue]"

#######
# clone
#######
echo "cloning $ORIG into $NAME. this could take a while"
virsh suspend $ORIG
virt-clone --original $ORIG --name $NAME --auto-clone || exit 10
virsh resume $ORIG

#######
# reset
#######
echo "please enter your password for resetting the clone $NAME"
sudo virt-sysprep -d $NAME --hostname $NAME --firstboot-command 'ssh-keygen -A' --root-password password:12345tgb || exit 20

###########
# boot-once
###########
echo "clone $NAME needs to be started once for ssh key generation"
virsh start $NAME || exit 30
echo "wating for $STIME"
sleep $STIME || exit 31
virsh shutdown $NAME || exit 32
echo "clone $NAME ready. please don't forget to change it's static ip"

#############################
echo "done"
