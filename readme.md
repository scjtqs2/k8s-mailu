# k8s 安装 [mailu](https://github.com/Mailu/Mailu) 个人邮局 
> 镜像支持 arm64和amd64
> 
> 配置文件以dnspod（腾讯云api）的验证方式来生成 ssl证书。
> 
> 配置文件中的 `--pod-network-cidr` 为 `172.16.0.0/12,fc00::/48 `。支持ipv4、ipv6双栈。
> 
> 例如在家里树莓派上的k8s伤安装 邮局， 邮件数据、mysql等存储在 mycloud、群晖 等支持nfs的nas
## 一、环境依赖
1. kubernetes（kubelete、kubectl、kubeadm） >= 1.23 [安装参考](https://github.com/scjtqs2/kubernets-installer)
2. helm >=v3.9     [安装参考](https://github.com/scjtqs2/kubernets-installer)
3. mysql >= 5.7
4. cert-manager >= 1.19          [安装参考](https://github.com/scjtqs2/kubernets-installer)
5. cert-manager-webhook-dnspod 插件 [安装参考](https://github.com/scjtqs2/kubernets-installer)
6. nfs 后端存储
7. 一个dns解析器（支持dnsesc，采用dot防污染的方式获取解析，邮件验证会用到）

## 二、配置环境
1. 创建命名空间：
   1. 执行`kubectl apply -f namespace.yaml`
2. 创建自定义dns配置(如果已经安装过这个，可以跳过)：
   1. 修改 `dns-custom.yaml`：
      1. `kube-ipam.ip`、`cni.projectcalico.org/ipAddrs`的ip地址，用来固定这个pod的ip，防止重启后ip变了。确保这个ip在你的 pod ip池中就行
      2. `COREDNS`的参数为 当前k8s环境的coredns的真实地址。
   2. 执行 `kubectl apply -f dns-custom.yaml`
3. 创建 nfs的 storageClass:
   1. 修改 `nfs.sh` 中的nfs地址和路径。
   2. 执行`bash nfs.sh`来初始化nfs的存储
4. 创建 pvc 存储：
   1. 修改`pvc.yaml` 中的配置。需要修改里面的 nfs地址、路径、存储大写限制。
   2. 执行 `kubectl apply -f pvc.yaml`

## 三、安装 mailu
1. 修改 `mailu-mailserver.yaml`文件
   1. dns： 如果调整过 `dns-custom.yaml`中的 ip地址，则需要将 `mailu-mailserver.yaml`中的 `172.16.119.119` 改成你配置的 ip
   2. config-common 这个 ConfigMap 的修改（配置文件拉到最下面，倒数第二大块）：
      1. `HOSTNAMES` 改成你自己用到的相关域名
      2. `DOMAIN` 改成你自己的根域名， 也就是邮箱 '@' 后面那部分。
      3. `SECRET_KEY` 自行修改
      4. `SITENAME` 改成你自己想要的名字
      5. `WEBSITE` 改成你自己的地址
      6. `REAL_IP_FROM` 改成 你自己的本地网段
      7. "Database settings" 部分改成你的数据库配置。mailu的和ROUNDCUBE的建议分别建立成两个不一样的库。
   3. `mailu-certificates` 配置文件最末尾的这个证书申请配置的修改，域名换成你自己的。
   4. `mailu-ingress` ingress 配置的修改。配置文件倒数第三个。里面所有的域名 换成你自己的。
2. 安装 mailu:
   1. 执行 `kubectl apply -f mailu-mailserver.yaml`

## 四、卸载
1. 删除 mailu： 
   1. 执行 `kubectl delete -f mailu-mailserver.yaml`
2. 删 pvc：
   1. 执行 `kubectl delete -f pvc.yaml`
3. 删 nfs存储配置
   1. 执行 `helm uninstall mailu-nfs  -n mailu-mailserver`
