### 报错信息

```
[init] Using Kubernetes version: v1.21.0
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 17.12.0-ce. Latest validated version: 20.10
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR Port-2379]: Port 2379 is in use
	[ERROR Port-2380]: Port 2380 is in use
	[ERROR DirAvailable--var-lib-etcd]: /var/lib/etcd is not empty
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

### 解决方法

1. 执行重置命令

   > ```
   > sudo kubeadm reset -f --cri-socket /var/run/crio/crio.sock
   > ```

2. 删除所有相关数据

   > ```
   > sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
   > ```

3. 刷新所有防火墙(iptables)规则

   >```
   >sudo iptables -F && iptables -X
   >sudo iptables -t nat -F && iptables -t nat -X
   >sudo iptables -t raw -F && iptables -t raw -X
   >sudo iptables -t mangle -F && iptables -t mangle -X
   >```

4. 重启Docker服务

   > ```
   > sudo systemctl restart docker
   > ```



```
sudo kubeadm reset -f --cri-socket /var/run/crio/crio.sock
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
sudo systemctl restart docker
```

