
##root password
password=$(date +%s | sha256sum | base64 | head -c 12)
echo -e "$password\n$password" | passwd root

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
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo apt-get upgrade -y 

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


##cephadm
echo "deb https://download.ceph.com/debian-octopus/ bionic main" > /etc/apt/sources.list.d/ceph.list
wget https://download.ceph.com/keys/release.asc
sudo apt-key add release.asc
rm release.asc 
sudo apt update -y
sudo apt install cephadm -y

## public keys
mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDzZaPLXXBlNE9kVBnCyg0micfujNVh+ew5owGG60nR7dlGTBz9PVKYQHOjxhW+V9m0KIltjpUQCsaRvpPMyJG6+xHoTB5tq+XugfIRyuvAu3BiQ23B01ryhTP6mRqkk7Nh6/tn8ISha4es5AxJov7+Cdj8br4AzmnhU4c++aHig4dVzhrC2Nm1y/autCFby8q852hZmsiZniBFk0ggNIYaGes5Yg2hHUJPXVVeYa6WhJvkF/RNd18r7ceGP4jclPXyeBvH9jbpRorlp9csLgtklgtJOhQCup3G9zw8rdZ57fFYBB1+R0jMp1YuTrHeKl8NipDhJb6v+7/kyvCf8Gb/mckPjpVkEukgKHsrVYhIVlg2ZZ9W28LEqC0P12WoqqFKE2jeMTI7lK4haeuaWwEDDM7L/2bWjAETQogU3oPR+mNcK4K2liwu7vk2AXtkKEH4D0va8pjCQiIpXbsm9e+DMeDRRWCnYoeWUOQY/ursXhC0gnG6UmV3bzQfEzm1p40= ceph-ae0bd11a-6639-11eb-9fa4-0050569051a7" > /root/.ssh/authorized_keys
