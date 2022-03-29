#!/bin/bash
echo "安装连接追踪工具"
sudo yum install conntrack -y
echo '安装时间同步工具'
sudo yum install ntpdate -y
echo '安装网络时间协议'
sudo yum install ntp -y
echo '安装LVS管理工具'
sudo yum install ipvsadm -y
echo 'iptable扩展包'
sudo yum install ipset -y
echo '命令行JSON 处理工具'
sudo yum install jq -y
echo 'http访问工具'
sudo yum install curl -y
echo '系统状态工具包'
sudo yum install sysstat -y
echo 'linux内核系统调用过滤帮助库'
sudo yum install libsecomp -y
echo '简单下载工具'
sudo yum install wget -y
echo '编辑工具'
sudo yum install vim -y
echo '网络相关工具包'
sudo yum install net-tools -y
echo '版本控制工具'
sudo yum install git -y

echo '停止防火墙'
sudo systemctl stop firewall
echo '禁用防火墙'
sudo systemctl disable firewall

echo '关闭swap分区'
sudo swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo '关闭SeLinux'
sudo setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disable' /etc/selinux/config

echo '优化内核参数'
cat > kubernates.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv6.conf.all.disable_ipv6=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
net.netfilter.nf_conntrack_max=2310720
vm.swappiness=0 # 禁止使用swap空间，只有当系统oom时才允许启用
vm.overcommit_memory=1 #不检查物理内存是否够用
vm.panic_on_oom=0 # 开启OOM
fs.inotify-max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
EOF

echo '复制到系统目录'
sudo mv kubernates.conf /etc/sysctl.d/kubernates.conf

echo '内核参数刷新'
sudo sysctl -p /etc/sysctl.d/kubernates.conf

echo '调整系统时区 为东京 ，服务器在东京'
sudo timedatectl set-timezone Asia/Tokyo

echo '将当前UTC时间写入硬件时钟'
sudo timedatectl set-local-rtc 0

echo '重启依赖时间的服务:日志服务'
sudo systemctl restart rsyslog

echo '重启依赖时间的服务:Job服务'
sudo systemctl restart crond
echo '关闭系统不需要的服务:邮件'
sudo systemctl stop postfix
sudo systemctl disable postfix

echo '设置日志系统配置'
sudo mkdir /var/log/journal/
sudo mkdir /etc/systemd/journald.conf.d
sudo cat > /etc/systemd/journald.conf.d/99-prophet.conf<<EOF
[Journal]
Storage=persistent
Compress=yes
SunIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000

SystemMaxUse=10G

SystemMaxFileSize=200M

MaxRetentionSec=2week

ForwardToSyslog=no
EOF
echo '重启日志服务'
sudo systemctl restart systemctl-journald

echo '升级系统内核到4.44'
sudo rpm -Uvh http://www/elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum --enablerepo=elrepo-kernel install -y kernel-lt

sudo grub2-set-default "CentOS linux (4.4.182-1.el7.elrepo.x86_64) 7 (Core)"

sudo reboot