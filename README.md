# clonevm

This simple script helps to create clones of a golden image. I used it to duplicate a prepared ubuntu server 20.04 image with enabled SSH and a static IP config.

The script checks that source vm exists and that target vm doesn't exist. If checks succeed the source vm is cloned with virt-clone and the new vm is cleaned with virt-sysprep. During the cleanup the root password is set. Existing user logins from source vm stay active.

## Installation & Usage

### Requirements

The script needs kvm and a source vm to operate.

#### KVM

```
sudo apt install lvm2 bridge-utils qemu qemu-kvm libvirt-daemon libvirt-clients virt-manager
```

#### KVM Guest Tools

```
sudo apt install libguestfs-tools
```

### Installation

```
git clone git@github.com:mbogner/clonevm.git
cd clonevm

# source...source virtual machine name
# target...target virtual machine name
./clonevm.sh <source> <target>
```

## Known Issues

Netplan configured static vms aren't changed. So on first startup change the netplan config (if there was a static ip config) and apply it. Sure this wouldn't be too hard to automate but I skipped that step as it only is a problem with static ip config - dhcp would't need that.