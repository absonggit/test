#!/bin/bash

ip_check () {
    echo "外网IP:$(curl -s ip.sb)"
    if [[ $(awk -F"[ .]" '{print $4}' /etc/redhat-release) == 7 ]]
    then
        echo "内网IP:$(ifconfig ens5 | grep inet | grep -v inet6 | awk '$2!="127.0.0.1"{print $2}')"
    else
        echo "内网IP:$(ifconfig ens5 | grep inet | grep -v inet6 | awk -F"[ :]+" '$4!="127.0.0.1"{print $4}')"
    fi
    echo "-----------------------"
}
hosts_check () {
    echo "【tcp_wrappers】"
    echo "-----------------------"
    echo "hosts.allow"
    grep -v "^#" /etc/hosts.allow || {
        echo "没有配置"
    }
    echo "hosts.deny"
    grep -v "^#" /etc/hosts.deny || {
        echo "没有配置"
    }
    echo
}

conn_check () {
    echo "【连接检测】"
    echo "-----------------------"
    netstat -ntlupa| awk -F"[ :/]+" '$8=="ESTABLISHED"&&$6!="127.0.0.1"&&$10!~"kube"&&$10!~"etcd"&&$10!~"ssh"&&$10!~"filebeat"&&$10!~"nginx"&&$10!~"flanne"&&$10!~"calico"&&$10!~"node_exporter"&&$10!~"agent"{print $0}'
}

items_check () {
    echo
    echo "【项目检测】"
    echo "------------------------------------"
    for path in $(find /home/group -mindepth 1 -maxdepth 1 -type d)
    do
        printf "%-15s %-30s\n" 文件数 项目目录
        file_count=$(find $path -path "$path/runtime" -prune -o -type f -print | wc -l)
        printf "%-10s %-30s\n" ${file_count} $path
        echo "24小时内修改过的文件"
        find $path ! -path "$path/resources/*" ! -path "$path/data/Runtime/*" ! -path "$path/runtime/*" ! -path "$path/data/runtime/*" -mtime 0 -type f  ! -name "*.png" -print || {
            echo none
        }
        echo "------------------------------------"
    done
}

root_file_check () {
    echo
    echo "【文件系统24小时内的文件修改】"
    echo "------------------------------------"
    find / \
    ! -path "/home/group/*" \
    ! -path "/tmp/sess_*" \
    ! -path "/proc/*" \
    ! -path "/sys/*" \
    ! -path "/usr/local/aegis/*" \
    ! -path "/usr/local/share/aliyun-assist/*" \
    ! -path "/var/log/*" \
    ! -path "/var/lib/yum/*" \
    ! -path "/home/wwwlogs/*" \
    ! -path "/var/lib/rpm/*" \
    ! -path "/var/cache/yum/*" \
    ! -path "/var/lib/filebeat/*" \
    ! -path "/var/lib/docker/*" \
    ! -path "/var/cache/man/*" \
    ! -path "/opt/app-yfb/*" \
    ! -path "/opt/admin-yfb/*" \
    ! -path "/run/systemd/*" \
    ! -path "/var/lib/kubelet/*" \
    ! -path "/var/lib/etcd/*" \
    ! -path "/run/containerd/*" \
    ! -path "/opt/rke/*" \
    ! -path "/run/docker/*" \
    ! -path "/var/lib/cni/*" \
    ! -path "/run/*" \
    ! -path "/var/spool/*" \
    -type f -mtime 0
}
shell_check () {
    echo
    echo "【shell进程检测】"
    echo "------------------------------------"
    ps aux | egrep -v "script|kube-controller-manager|containerd|sshd|pts|filebeat|flush|mysql|metricbeat|sftp-server" | grep sh
}
code_check () {
    echo
    echo "【项目代码检测】"
    echo "------------------------------------"
    find /home/group -type f -name "*.php" -exec grep -Hn bash {} \; | egrep -v "foreach" || echo none
}
ip_check
hosts_check
conn_check
items_check 
root_file_check
shell_check
code_check
date
