
##root password
password=$(date +%s | sha256sum | base64 | head -c 12)
echo -e "$password\n$password" | passwd root

## Network Drivers (download only)
apt update && apt upgrade -y
cd /root && wget https://content.mellanox.com/ofed/MLNX_OFED-5.2-1.0.4.0/MLNX_OFED_LINUX-5.2-1.0.4.0-ubuntu18.04-x86_64.tgz
cd /root && tar -xzf MLNX_OFED_LINUX-4.9-2.2.4.0-ubuntu18.04-x86_64.tgz
#cd MLNX_OFED_LINUX-5.2-1.0.4.0-ubuntu18.04-x86_64
#sudo ./mlnxofedinstall —upstream-libs —dpdk

##kernel
wget -O /usr/local/bin/ https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
chmod +x /usr/local/bin/ubuntu-mainline-kernel.sh
sudo /usr/local/bin/ubuntu-mainline-kernel.sh -i 5.10.1 --yes


##docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io -y
sudo apt-get upgrade -y 

##install jumpcloud
curl --tlsv1.2 --silent --show-error --header 'x-connect-key: 64da8e09f6c0f4f9b863a96aae2fec356a1da795' https://kickstart.jumpcloud.com/Kickstart | sudo bash

##sysctl

echo "net.ipv4.tcp_window_scaling=1
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 87380 33554432
net.ipv4.tcp_congestion_control=bbr
fs.file-max=1048576
net.ipv4.ip_local_port_range = 12000 65535
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=10
net.core.somaxconn=1024
net.core.netdev_max_backlog=100000
net.ipv4.tcp_max_syn_backlog=30000
net.ipv4.tcp_max_tw_buckets=2000000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_adv_win_scale=2
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.core.default_qdisc=fq
fs.inotify.max_user_watches=131072
net.core.netdev_budget=50000
net.core.netdev_budget_usecs=5000" > /etc/sysctl.conf

sysctl -p

## wipe any disks with LVM on them (incase of reinstall)
diskfile="/tmp/diskfile"
hostname=$(hostname)

blkid  | grep "LVM"  | awk -F' ' '{print $1}' | sed  's/.$//' > $diskfile

while read line; do
      wipefs -a -f $line
      dd if=/dev/zero of=$line bs=512 count=2;
done < $diskfile

## Put hosts file correctly

echo "172.16.1.11 cnode1
172.16.1.12 cnode2
172.16.1.13 cnode3
172.16.1.14 cnode4
172.16.1.15 cnode5
172.16.1.16 cnode6
172.16.1.17 cnode7
172.16.1.18 cnode8
172.16.1.19 cnode9
172.16.1.20 cnode10
172.16.1.23 cnode11
172.16.1.24 cnode12
172.16.1.21 cmgr1
172.16.1.22 cmgr2" >> /etc/hosts
