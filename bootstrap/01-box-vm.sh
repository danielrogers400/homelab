# on the remote machine - set up hostname & SSH
echo box-vm > /etc/hostname
apt install openssh-server -y
exit

#on the local, upload ssh key. password will be requested
HOST_ADDRESS=192.168.0.211
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
      addresses: [192.168.0.211/24]
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
         addresses: [192.168.0.1]
' > /etc/netplan/01-netcfg.yaml
#set up colors
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
source ~/.bashrc
#Add ansible user
useradd -m -s /bin/bash ansible
usermod -aG sudo ansible
echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
#apply net changes, connection will drop when address changes
sudo netplan apply

reboot