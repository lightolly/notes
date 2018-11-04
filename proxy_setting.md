
## 创建网桥桥接eth2-eth4

## eth1作为wan

## 安装代理工具
    wget https://install.direct/go.sh
    从https://v2ray.com/download下载安装包
    ./go.sh --local xxxx 安装
    修改/etc/v2ray/config.json文件见proxy_setting.json
    systemctl enable v2ray
    systemctl start v2ray

## 配置内核参数
    vim /etc/sysctl.conf
    net.ipv4.ip_forward=1
    net.netfilter.nf_conntrack_tcp_timeout_established=7200
    net.netfilter.nf_conntrack_sctp_timeout_established=7200
    net.core.default_qdisc=fq
    net.ipv4.tcp_congestion_control=bbr
    
    sysctl -p

## 开启snat，br0开启dhcp

    yum install iptables-service -y
    systemctl enable iptables
    systemctl start iptables

# 透明代理TCP

    iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE
    iptables -t nat -N V2RAY
    iptables -t nat -I V2RAY -d 127.0.0.0/8 -j RETURN
    iptables -t nat -I V2RAY -d 服务IP -j RETURN
    iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN 
    iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff
    iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 12345
    iptables -t nat -A PREROUTING -p tcp -j V2RAY
    iptables -t nat -A OUTPUT -p tcp -j V2RAY

# 透明代理UDP
    ip rule add fwmark 1 table 100
    ip route add local 0.0.0.0/0 dev lo table 100
    iptables -t mangle -N V2RAY_MASK
    iptables -t mangle -I V2RAY_MASK -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MASK -d 服务器IP -j RETURN
    iptables -t mangle -A V2RAY_MASK -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A V2RAY_MASK -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MASK -p udp -j TPROXY --on-port 12345 --tproxy-mark 1
    iptables -t mangle -A PREROUTING -p udp -j V2RAY_MASK

## 保存iptables
    service iptables save
## 策略路由自启动
    chmod +x /etc/rc.d/rc.local
将如下自启动项目加入
    ip rule add fwmark 1 table 100
    ip route add local 0.0.0.0/0 dev lo table 100


# 使能ipv6透传
    ebtables -t broute -A BROUTING -p ! ipv6 -j DROP -i enp1s0
    brctl addif br0 enp1s0
