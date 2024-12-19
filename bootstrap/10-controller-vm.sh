# on the remote machine - set up hostname & SSH
echo controller-vm > /etc/hostname
apt install openssh-server -y
exit

#on the local, upload ssh key. password will be requested
HOST_ADDRESS=192.168.0.250
ssh-copy-id -i /c/Users/Daniel/.ssh/id_rsa daniel@$HOST_ADDRESS

#ssh back in to remote and set the IP address
ssh daniel@$HOST_ADDRESS
echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
rm /etc/netplan/50-cloud-init.yaml
echo 'network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      accept-ra: no
      addresses: [192.168.0.250/24]
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
         addresses: [192.168.0.1]
' > /etc/netplan/01-netcfg.yaml
#apply net changes, connection will drop when address changes
sudo netplan apply
#set up colors
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
source ~/.bashrc
#Generate ssh key
ssh-keygen -f /home/daniel/.ssh/id_rsa -t rsa -q -P ""
#change user to daniel, in case previous was ran by root
chown daniel:daniel /home/daniel/.ssh/id_rsa
chown daniel:daniel /home/daniel/.ssh/id_rsa.pub 

#############
# ansible user doesn't have a password so we first upload the public key 
# to /home/daniel, then copy it to /home/ansible
#############

#### BOX ####
BOX_VM_ADDRESS=192.168.0.211
ssh-copy-id -i /home/daniel/.ssh/id_rsa.pub daniel@$BOX_VM_ADDRESS
ssh daniel@$BOX_VM_ADDRESS
sudo -i
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
cat /etc/ssh/sshd_config | grep PasswordAuthentication
mkdir -p /home/ansible/.ssh
cp /home/daniel/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
systemctl restart ssh
exit

#### LAPTOP ####
LAPTOP_VM_ADDRESS=192.168.0.212
ssh-copy-id -i /home/daniel/.ssh/id_rsa.pub daniel@$LAPTOP_VM_ADDRESS
ssh daniel@$LAPTOP_VM_ADDRESS
sudo -i
mkdir -p /home/ansible/.ssh
cp /home/daniel/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
systemctl restart ssh
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
cat /etc/ssh/sshd_config | grep PasswordAuth
exit

reboot

##############
apt update
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible -y