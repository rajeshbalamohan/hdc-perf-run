sysctl -w "net.core.somaxconn=16384"
sysctl -w "net.core.netdev_max_backlog=20000"
sysctl -w "net.core.rmem_max=134217728"
sysctl -w "net.core.wmem_max=134217728"
sysctl -w "net.core.rmem_default=524288"
sysctl -w "net.core.wmem_default=524288"
sysctl -w "net.ipv4.tcp_rmem=4096 65536 134217728"
sysctl -w "net.ipv4.tcp_wmem=4096 65536 134217728"
sysctl -w "net.ipv4.ip_local_port_range=4096 61000"
sysctl -w "net.ipv4.tcp_mtu_probing=1"
sysctl -w "net.ipv4.tcp_fin_timeout=4"
sysctl -w "net.ipv4.conf.lo.forwarding=0"
sysctl -w "vm.dirty_background_ratio=80"
sysctl -w "vm.dirty_ratio=80"
sysctl -w "vm.swappiness=0"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
